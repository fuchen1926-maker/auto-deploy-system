#!/bin/bash
set -e

echo ""
echo "==========================================="
echo "🚀 Auto Deploy Platform Installer v6.0 (Alibaba Cloud Linux)"
echo "==========================================="
echo ""

echo "=== Step 1. Install Base Tools ==="
dnf install -y git curl wget --skip-broken || true

echo "=== Step 2. Enable EPEL ==="
dnf remove -y epel-release epel-aliyuncs-release || true
dnf install -y epel-release --allowerasing || true

echo "=== Step 3. Install Node.js 18 ==="
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
dnf install -y nodejs

echo "=== Step 4. Install PM2 ==="
npm install -g pm2

echo "=== Step 5. Create Install Directory ==="
mkdir -p /opt/auto-deploy-system

echo "=== Step 6. Download deploy.sh ==="
curl -sSL https://raw.githubusercontent.com/fuchen1926-maker/auto-deploy-system/main/deploy.sh -o /opt/auto-deploy-system/deploy.sh
chmod +x /opt/auto-deploy-system/deploy.sh

echo ""
echo "==========================================="
echo "✔️ Installation Complete!"
echo "==========================================="
echo ""
echo "Next Step:"
echo "  bash /opt/auto-deploy-system/deploy.sh <domain> <frontend_git> <backend_git> <port>"
echo ""
