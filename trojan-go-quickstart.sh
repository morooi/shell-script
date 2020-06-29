#!/bin/sh

echo "Getting the latest version of trojan-go"
latest_version="$(curl -fsSL https://api.github.com/repos/p4gefau1t/trojan-go/releases | grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')"
echo "${latest_version}"
trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/${latest_version}/trojan-go-linux-amd64.zip"

mkdir -p "/usr/bin/trojan-go"
mkdir -p "/etc/trojan-go"

cd `mktemp -d`
wget -nv "${trojango_link}" -O trojan-go.zip
unzip -q trojan-go.zip && rm -rf trojan-go.zip

mv trojan-go /usr/bin/trojan-go/trojan-go
mv example/trojan-go.service /etc/systemd/system/trojan-go.service
wget https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat -O geosite.dat
wget https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat -O geoip.dat
mv geoip.dat /etc/trojan-go/geoip.dat
mv geosite.dat /etc/trojan-go/geosite.dat
# if config.json didn't exist, use the example server.json 
if [ ! -f "/etc/trojan-go/config.json" ]; then
  mv example/server.json /etc/trojan-go/config.json
fi

systemctl daemon-reload
systemctl reset-failed

echo "trojan-go is installed."