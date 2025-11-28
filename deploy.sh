#!/bin/bash
set -e

echo ""
echo "==========================================="
echo "⚡ Auto Deploy System v6.3 (1Panel + OpenResty)"
echo "==========================================="
echo ""

if [ "$#" -ne 4 ]; then
    echo "用法: bash deploy.sh <domain> <frontend_git> <backend_git> <backend_port>"
    exit 1
fi

DOMAIN=$1
FE_GIT=$2
BE_GIT=$3
PORT=$4

BASE=/home/admin/$DOMAIN
FE_DIR=$BASE/frontend
BE_DIR=$BASE/backend

echo "📌 域名       : $DOMAIN"
echo "📌 前端 Git   : $FE_GIT"
echo "📌 后端 Git   : $BE_GIT"
echo "📌 后端 Port  : $PORT"
echo ""

mkdir -p $FE_DIR $BE_DIR

echo "=== 1. 克隆仓库 ==="
git clone $FE_GIT $FE_DIR || true
git clone $BE_GIT $BE_DIR || true

echo "=== 2. 构建前端 ==="
cd $FE_DIR

if [ -f "package.json" ]; then
    echo "📦 检测到前端项目，执行 npm install + npm run build"
    npm install
    npm run build
else
    echo "🌐 检测到静态 HTML 前端，跳过构建步骤"
fi

echo "=== 3. 安装后端依赖 ==="
cd $BE_DIR
npm install --production

echo "=== 4. 自动检测 .env ==="
if [ -f "$BE_DIR/.env" ]; then
    echo "✅ 检测到 .env 文件"
else
    echo "⚠️ 未找到 .env，请上传至：$BE_DIR/.env"
fi

echo "=== 5. 自动检测后端入口文件 ==="

if [ -f "$BE_DIR/server.js" ]; then
    ENTRY="server.js"
elif [ -f "$BE_DIR/app.js" ]; then
    ENTRY="app.js"
elif [ -f "$BE_DIR/index.js" ]; then
    ENTRY="index.js"
else
    echo "❌ 未找到入口文件（server.js / app.js / index.js 均不存在）"
    exit 1
fi

echo "👉 使用后端入口：$ENTRY"

echo "=== 6. 配置 PM2 ==="
pm2 delete $DOMAIN-backend 2>/dev/null || true
pm2 start $BE_DIR/$ENTRY --name $DOMAIN-backend
pm2 save

echo "=== 7. 查找 OpenResty 容器 ==="
CID=$(docker ps -qf "name=1Panel-openresty")
if [ -z "$CID" ]; then
    echo "❌ 未找到 OpenResty 容器，请检查 1Panel 安装"
    exit 1
fi

echo "🔍 OpenResty 容器ID：$CID"

HOST_IP="172.17.0.1"

echo "=== 8. 生成 Nginx 配置 ==="

NGINX_CONF="/opt/1panel/apps/openresty/openresty/conf/conf.d/$DOMAIN.conf"

cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $FE_DIR/dist;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://$HOST_IP:$PORT/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "=== 9. 重载 OpenResty ==="
docker exec $CID nginx -t
docker exec $CID nginx -s reload

echo ""
echo "🎉 部署成功：http://$DOMAIN"
echo "👉 HTTPS 请前往 1Panel → SSL 配置"
echo ""
