# 🚀 Auto Deploy System v6.0
适用于 **1Panel + OpenResty + Node.js 全自动化前后端部署平台**

---

## ✨ 功能
- 一键安装环境（Node / PM2 / Certbot / Git）
- 自动克隆前后端 GitHub 仓库
- 自动构建前端
- 自动安装后端依赖
- 自动 PM2 后端守护
- 自动生成 OpenResty Nginx 配置（1Panel）
- 自动 reload OpenResty
- 支持无限多项目隔离部署

---

## 📦 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fuchen1926-maker/auto-deploy-system/main/install.sh)
