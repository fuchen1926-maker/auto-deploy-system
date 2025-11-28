#!/bin/bash
set -e

echo ""
echo "==========================================="
echo "🚀 自动部署平台 Install Script v6.0"
echo "==========================================="
echo ""

# 0. root 检查
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 root 权限运行"
    exit 1
fi

# 1. 基本环境
echo "=== 1. 安装基础工具 ==="
dnf install -y epel-release git curl wget unzip nano

# 2. Node.js LTS
echo "=== 2. 安装 Node.js 18 LTS ==="
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
dnf install -y nodejs

# 3. PM2
echo "=== 3. 安装 PM2 ==="
npm install -g pm2

# 4. Nginx（使用系统自身，不影响 1Panel OpenResty）
echo "=== 4. 安装 Nginx（备用） ==="
dnf install -y nginx || true

# 5. Certbot
echo "=== 5. 安装 Certbot（HTTPS 自动签发） ==="
dnf install -y certbot python3-certbot-nginx || true

# 6. 部署脚本
echo "=== 6. 下载最新 deploy.sh ==="
curl -fsSL https://raw.githubusercontent.com/fuchen1926-maker/auto-deploy-system/main/deploy.sh \
    -o /usr/local/bin/deploy
chmod +x /usr/local/bin/deploy

echo ""
echo "==========================================="
echo "🎉 自动部署平台 已安装完成"
echo "🚀 使用命令： deploy <domain> <frontend_git> <backend_git> <port>"
echo ""
echo "示例："
echo "deploy lovebrain.ai https://github.com/.../fe https://github.com/.../be 3000"
echo "==========================================="
