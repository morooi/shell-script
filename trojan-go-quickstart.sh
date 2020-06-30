#!/usr/bin/env bash

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
sh_ver="0.1.3"

function prompt() {
  while true; do
    read -p "$1 [y/N] " yn
    case $yn in
    [Yy]) return 0 ;;
    [Nn] | "") return 1 ;;
    esac
  done
}

if [[ $(id -u) != 0 ]]; then
  echo Please run this script as root.
  exit 1
fi

if [[ $(uname -m 2>/dev/null) != x86_64 ]]; then
  echo Please run this script on x86_64 machine.
  exit 1
fi

osRelease=""
osSystemPackage=""
osSystemmdPath=""

function getLinuxOSVersion() {
  # copy from 秋水逸冰 ss scripts
  if [[ -f /etc/redhat-release ]]; then
    osRelease="centos"
    osSystemPackage="yum"
    osSystemmdPath="/usr/lib/systemd/system/"
  elif cat /etc/issue | grep -Eqi "debian"; then
    osRelease="debian"
    osSystemPackage="apt-get"
    osSystemmdPath="/lib/systemd/system/"
  elif cat /etc/issue | grep -Eqi "ubuntu"; then
    osRelease="ubuntu"
    osSystemPackage="apt-get"
    osSystemmdPath="/lib/systemd/system/"
  elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    osRelease="centos"
    osSystemPackage="yum"
    osSystemmdPath="/usr/lib/systemd/system/"
  elif cat /proc/version | grep -Eqi "debian"; then
    osRelease="debian"
    osSystemPackage="apt-get"
    osSystemmdPath="/lib/systemd/system/"
  elif cat /proc/version | grep -Eqi "ubuntu"; then
    osRelease="ubuntu"
    osSystemPackage="apt-get"
    osSystemmdPath="/lib/systemd/system/"
  elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    osRelease="centos"
    osSystemPackage="yum"
    osSystemmdPath="/usr/lib/systemd/system/"
  fi
}

do_service() {
  if [[ $systemd ]]; then
    systemctl $1 $2
  else
    service $2 $1
  fi
}

NAME=trojan-go
TROJAN_GO_VER_LATEST=$(curl -fsSL https://api.github.com/repos/p4gefau1t/trojan-go/releases | grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOADURL="https://github.com/p4gefau1t/trojan-go/releases/download/${TROJAN_GO_VER_LATEST}/trojan-go-linux-amd64.zip"
TMPDIR="$(mktemp -d)"
INSTALLPREFIX=/usr/local
SYSTEMDPREFIX=/etc/systemd/system

BINARYPATH="${INSTALLPREFIX}/bin/${NAME}"
CONFIGPATH="${INSTALLPREFIX}/etc/${NAME}/config.json"
SYSTEMDPATH="${SYSTEMDPREFIX}/${NAME}.service"

install_trojan_go() {
  ${osSystemPackage} install wget unzip -y

  echo "最新版本: ${TROJAN_GO_VER_LATEST}"

  echo Entering temp directory ${TMPDIR}...
  cd ${TMPDIR}

  echo Downloading ${NAME} ${TROJAN_GO_VER_LATEST}...
  wget -q "${DOWNLOADURL}" -O trojan-go.zip
  unzip -q trojan-go.zip && rm -rf trojan-go.zip
  cd ${NAME}

  echo Installing ${NAME} ${TROJAN_GO_VER_LATEST} to ${BINARYPATH}...
  install -Dm755 "${NAME}" "${BINARYPATH}"

  echo Installing ${NAME} server config to ${CONFIGPATH}...
  if ! [[ -f "${CONFIGPATH}" ]] || prompt "The server config already exists in ${CONFIGPATH}, overwrite?"; then
    mkdir ${INSTALLPREFIX}/etc/${NAME}
    cat >"${CONFIGPATH}" <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "your_password"
    ],
    "ssl": {
        "cert": "your_cert.crt",
        "key": "your_key.key",
        "sni": "your-domain-name.com"
    },
    "router":{
        "geoip": "${INSTALLPREFIX}/etc/${NAME}/geoip.dat",
        "geosite": "${INSTALLPREFIX}/etc/${NAME}/geosite.dat",
        "enabled": true,
        "block": [
            "geoip:private"
        ]
    }
}
EOF
  else
    echo Skipping installing ${NAME} server config...
  fi

  if [[ -d "${SYSTEMDPREFIX}" ]]; then
    echo Installing ${NAME} systemd service to ${SYSTEMDPATH}...
    if ! [[ -f "${SYSTEMDPATH}" ]] || prompt "The systemd service already exists in ${SYSTEMDPATH}, overwrite?"; then
      cat >"${SYSTEMDPATH}" <<EOF
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart="${BINARYPATH}" -config "${CONFIGPATH}"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
      echo Reloading systemd daemon...
      systemctl daemon-reload
    else
      echo Skipping installing $NAME systemd service...
    fi
  fi

  echo Updating geoip/geosite files...
  wget https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat -O ${INSTALLPREFIX}/etc/${NAME}/geosite.dat
  wget https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat -O ${INSTALLPREFIX}/etc/${NAME}/geoip.dat

  echo 删除临时目录 ${TMPDIR}...
  rm -rf "${TMPDIR}"

  echo -e "Trojan-go 安装成功! 请修改配置文件: ${CONFIGPATH}"
}

update_trojan_go() {
  if [[ ${trojan_go_ver} != ${TROJAN_GO_VER_LATEST} ]]; then
    echo -e " ${Green_font_prefix} 发现新版本..正在更新..${Font_color_suffix}"
    echo
    echo -e "最新版本: ${TROJAN_GO_VER_LATEST}"

    echo -e "Entering temp directory ${TMPDIR}..."
    cd ${TMPDIR}

    echo -e "Downloading ${NAME} ${TROJAN_GO_VER_LATEST}..."
    wget -q "${DOWNLOADURL}" -O trojan-go.zip
    unzip -q trojan-go.zip && rm -rf trojan-go.zip
    cd ${NAME}

    install -Dm755 "${NAME}" "${BINARYPATH}"

    do_service restart trojan-go
    echo
    echo -e " ${Green_font_prefix} 更新成功..${Font_color_suffix} 当前 Trojan-go 版本: $v2ray_latest_ver"
  else
    echo && echo -e "${Green_font_prefix}没有发现新版本..${Font_color_suffix}"
  fi
}

update_trojan_go_sh() {
  echo -e "当前版本为 ${Green_font_prefix}v${sh_ver}${Font_color_suffix}, 开始检测最新版本.."
  sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/morooi/shell-script/master/trojan-go-quickstart.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${Red_font_prefix}[错误]${Font_color_suffix} 检测最新版本失败 !" && start_menu

  if [[ ${sh_new_ver} != ${sh_ver} ]]; then
    echo -e "发现新版本[ v${sh_new_ver} ], 是否更新？[Y/n]"
    read -p "(默认: y):" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ ${yn} == [Yy] ]]; then
      wget -N --no-check-certificate https://raw.githubusercontent.com/morooi/shell-script/master/trojan-go-quickstart.sh && chmod +x trojan-go-quickstart.sh
      echo -e "脚本已更新为最新版本 v${sh_new_ver} !"
    else
      echo && echo "已取消..." && echo
    fi
  else
    echo
    echo -e "当前已是最新版本 v.${sh_new_ver}!"
  fi
}

uninstall_trojan_go() {
  if prompt "是否卸载 Trojan-go"; then
    is_uninstall_trojan_go=true
    echo -e "卸载 Trojan-go = ${Green_font_prefix}是${Font_color_suffix}"
  else
    echo
    echo -e "卸载已取消..."
  fi

  if [[ ${is_uninstall_trojan_go} ]]; then
    [ ${trojan_go_pid} ] && do_service stop trojan-go
    rm -rf ${INSTALLPREFIX}/etc/${NAME}
    rm -rf ${BINARYPATH}

    systemctl disable trojan-go >/dev/null 2>&1
    rm -rf ${SYSTEMDPATH}
    echo -e "Trojan-go 卸载完成...."
  fi
}

start_menu() {
  clear
  getLinuxOSVersion
  echo && echo -e "  Trojan-go 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- morooi.cn --
  
  ${Green_font_prefix}1.${Font_color_suffix} 安装 Trojan-go
  ${Green_font_prefix}2.${Font_color_suffix} 升级 Trojan-go
  ${Green_font_prefix}3.${Font_color_suffix} 升级 Trojan-go 一键安装管理脚本
  ${Green_font_prefix}4.${Font_color_suffix} 卸载 Trojan-go
  ${Green_font_prefix}5.${Font_color_suffix} 退出脚本
  ————————————————————————————————" && echo

  if [[ ! -f ${BINARYPATH} ]]; then
    echo -e "  当前状态: ${Green_font_prefix}未安装 ${Font_color_suffix}Trojan-go, ${Red_font_prefix}请先安装${Font_color_suffix}"
  else
    trojan_go_ver="$(${BINARYPATH} -version | head -n 1 | cut -d " " -f2)"
    trojan_go_pid=$(pgrep -f ${BINARYPATH})

    if [ ${trojan_go_pid} ]; then
      trojan_go_status="${Green_font_prefix}正在运行${Font_color_suffix}"
    else
      trojan_go_status="${Red_font_prefix}未在运行${Font_color_suffix}"
    fi

    echo -e "  当前状态: ${Green_font_prefix}已安装 ${trojan_go_ver}${Font_color_suffix}, 最新版本为 ${Green_font_prefix}${TROJAN_GO_VER_LATEST}${Font_color_suffix}, Trojan-go 状态: ${trojan_go_status}"
  fi

  echo
  read -p "请输入数字 [1-5]:" num
  case "$num" in
  1)
    install_trojan_go
    ;;
  2)
    update_trojan_go
    ;;
  3)
    update_trojan_go_sh
    ;;
  4)
    uninstall_trojan_go
    ;;
  5)
    exit 1
    ;;
  *)
    echo -e "${Red_font_prefix}[错误]${Font_color_suffix}:请输入正确数字 [1-5]"
    sleep 1s
    start_menu
    ;;
  esac
}

start_menu
