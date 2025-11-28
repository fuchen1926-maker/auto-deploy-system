#!/bin/bash
set -e

echo ""
echo "==========================================="
echo "⚡ Auto Deploy System v6.0 (1Panel + OpenResty)"
echo "==========================================="
echo ""

if [ "$#" -ne 4 ]; then
    echo "用法: deploy <domain> <frontend_git> <backend_git> <backend_port>"
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
npm install
npm run build

echo "=== 3. 构建后端 ==="
cd $BE_DIR
npm install --production

echo "=== 4. 检查 .env ==="
if [ -f "$BE_DIR/.env" ]; then
    echo "✔ 已检测到 .env"
else
    echo "⚠️ 未找到 .env，请上传到 $BE_DIR/.env"
fi

echo "=== 5. PM2 启动后端 ==="
pm2 delete $DOMAIN-backend 2>/dev/null || true
pm2 start $BE_DIR/server.js --name $DOMAIN-backend
pm2 save

echo "=== 6. 获取 OpenResty 容器 ==="
CID=$(docker ps -qf "name=1Panel-openresty")
if [ -z "$CID" ]; then
    echo "❌ 未找到 OpenResty 容器"
    exit 1
fi
echo "OpenResty 容器：$CID"

HOST_IP="172.17.0.1"

echo "=== 7. 写入 Nginx 配置 ==="
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

echo "=== 8. 重载 OpenResty ==="
docker exec $CID nginx -t
docker exec $CID nginx -s reload

echo ""
echo "🎉 项目部署成功：http://$DOMAIN"
echo "👉 如需 HTTPS：请到 1Panel → SSL 管理 中申请"
echo ""
