#!/bin/bash
set -e

echo "==========================================="
echo "🛠 Auto Deploy System Installer v7.0"
echo "==========================================="

INSTALL_DIR="/opt/auto-deploy-system"
mkdir -p $INSTALL_DIR

curl -sSL https://raw.githubusercontent.com/fuchen1926-maker/auto-deploy-system/main/deploy.sh \
  -o $INSTALL_DIR/deploy.sh

chmod +x $INSTALL_DIR/deploy.sh

echo ""
echo "✔️ Install complete!"
echo "下一步执行："
echo ""
echo "  bash /opt/auto-deploy-system/deploy.sh <project> <fe_git> <be_git> <port>"
echo ""
