#!/bin/bash
set -e

# ============================
# 配置参数（请修改）
# ============================
DOMAIN_OR_IP="你的服务器IP或域名"
NEZHA_BACKEND="127.0.0.1:8008"   # 哪吒面板 API 服务地址
THEME_VERSION="v1.0"             # 主题版本
THEME_STYLE="style2.zip"         # style1.zip 或 style2.zip

# ============================
# 安装依赖 & Caddy
# ============================
echo "[+] 安装 Caddy..."
apt update -y
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl unzip
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update -y
apt install -y caddy

# ============================
# 下载主题
# ============================
echo "[+] 下载主题文件..."
mkdir -p /var/www/nezha-theme-world-map
cd /var/www/nezha-theme-world-map
wget -O theme.zip "https://github.com/reg233/nezha-theme-world-map/releases/download/${THEME_VERSION}/${THEME_STYLE}"
unzip -o theme.zip
rm -f theme.zip

# ============================
# 配置 Caddy（仅 HTTP，无证书）
# ============================
echo "[+] 写入 Caddy 配置..."
cat <<EOF >/etc/caddy/Caddyfile
:808 {
  root * /var/www/nezha-theme-world-map
  encode zstd gzip
  file_server

  @path {
    path /api/* /ws
  }

  reverse_proxy @path ${NEZHA_BACKEND}
}
EOF

# ============================
# 启动 Caddy
# ============================
echo "[+] 重启 Caddy..."
systemctl restart caddy
systemctl enable caddy

echo
echo "============================"
echo " 部署完成！"
echo " 访问地址: http://${DOMAIN_OR_IP}/"
echo " 后端 API: ${NEZHA_BACKEND}"
echo "============================"
