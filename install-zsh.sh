#!/usr/bin/env bash

# 安装 zsh 和 oh-my-zsh 并配置插件

# fonts color
red() {
    echo -e "\033[31m$1\033[0m"
}
green() {
    echo -e "\033[32m$1\033[0m"
}
yellow() {
    echo -e "\033[33m$1\033[0m"
}
blue() {
    echo -e "\033[34m$1\033[0m"
}
bold() {
    echo -e "\033[1m$1\033[0m"
}

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

install_zsh() {
    green "=============================="
    yellow "准备安装 zsh"
    red "(请保证全程能流畅访问 Github)"
    green "=============================="

    if [ "$osRelease" == "debian" -a $(id -u) != 0 ]; then
        echo -e " 请使用 root 用户运行"
        exit 1
    fi

    if [ "$osRelease" == "centos" ]; then
        sudo $osSystemPackage install zsh -y
        $osSystemPackage install util-linux-user -y
    elif [ "$osRelease" == "ubuntu" ]; then
        sudo $osSystemPackage install zsh -y
    elif [ "$osRelease" == "debian" ]; then
        $osSystemPackage install zsh -y
    fi
    
    echo
    yellow "== zsh 安装成功 =="
    echo
}

install_oh_my_zsh() {
    green "=============================="
    yellow "安装 oh-my-zsh"
    green "=============================="

    if [ "$osRelease" == "debian" ]; then
        $osSystemPackage install curl wget git -y
    else
        sudo $osSystemPackage install curl wget git -y
    fi

    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    red "oh-my-zsh 安装完成，请切换至 zsh 后配置 oh-my-zsh"
}

config_oh_my_zsh() {
    green "=============================="
    yellow "配置 oh-my-zsh"
    green "=============================="

    if [ "$osRelease" == "debian" ]; then
        $osSystemPackage install curl wget git -y
    else
        sudo $osSystemPackage install curl wget git -y
    fi

    if [[ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        yellow "安装 zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi

    if [[ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        yellow "安装 zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    fi

    if [[ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-completions" ]]; then
        yellow "安装 zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
    fi

    zshConfig=${HOME}/.zshrc
    zshTheme="ys"
    sed -i 's/ZSH_THEME=.*/ZSH_THEME="'${zshTheme}'"/' $zshConfig
    sed -i 's/# HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' $zshConfig
    sed -i 's/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting extract z)/' $zshConfig
    sed -i "s/# zstyle ':omz:update' mode auto/zstyle ':omz:update' mode auto/" $zshConfig
    sed -i "s/# zstyle ':omz:update' frequency 13/zstyle ':omz:update' frequency 7/" $zshConfig

    echo "export TERM=xterm-256color" >> ${HOME}/.zshrc
    # autoload -U compinit && compinit
    # source ${HOME}/.zshrc
    green "oh-my-zsh 配置成功, 请重新登陆服务器..."
}

start_menu() {
  getLinuxOSVersion
  echo "zsh, oh-my-zsh 部署脚本"
  echo "-- morooi.cn --"
  
  green "1. 安装 zsh"
  green "2. 安装 oh-my-zsh"
  green "3. 配置 oh-my-zsh 主题、插件"
  green "4. 全部执行"
  green "5. 退出脚本"

  echo
  read -p "请输入数字 [1-4]:" num
  case "$num" in
  1)
    install_zsh
    ;;
  2)
    install_oh_my_zsh
    ;;
  3)
    config_oh_my_zsh
    ;;
  4)
    install_zsh
    install_oh_my_zsh
    config_oh_my_zsh
    ;;
  5)
    exit 1
    ;;
  *)
    echo -e "${Red_font_prefix}[错误]${Font_color_suffix}:请输入正确数字 [1-4]"
    start_menu
    ;;
  esac
}

start_menu
