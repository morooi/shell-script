#!/usr/bin/env bash

# 安装 zsh 和 oh-my-zsh 并配置插件

# fonts color
red() {
    echo -e "\[\033[0;31m\]"
}
green() {
    echo -e "\[\033[0;32m\]"
}
yellow() {
    echo -e "\[\033[0;33m\]"
}
blue() {
    echo -e "\[\033[0;34m\]"
}
bold() {
    echo -e "\033[1m\033[01m$1\033[0m"
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

    getLinuxOSVersion
    # sudo $osSystemPackage update -y
    sudo $osSystemPackage install curl wget git -y

    if [ "$osRelease" == "centos" ]; then
        sudo $osSystemPackage install zsh -y
        $osSystemPackage install util-linux-user -y
    elif [ "$osRelease" == "ubuntu" ]; then
        sudo $osSystemPackage install zsh -y
    elif [ "$osRelease" == "debian" ]; then
        sudo $osSystemPackage install zsh -y
    fi

    echo
    yellow "==zsh 安装成功=="
    echo
    echo
}

install_oh_my_zsh() {
    green "=============================="
    yellow "安装 oh-my-zsh"
    green "=============================="

    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    yellow "安装 zsh-syntax-highlighting..."
    if [[ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi

    yellow "安装 zsh-autosuggestions..."
    if [[ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    fi

    zshConfig=${HOME}/.zshrc
    zshTheme="ys"
    sed -i 's/ZSH_THEME=.*/ZSH_THEME="'${zshTheme}'"/' $zshConfig
    sed -i 's/# HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' $zshConfig
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting extract z)/' $zshConfig

    yellow "切换默认 shell 为 zsh"
    zsh=$(which zsh)
    if ! chsh -s "$zsh"; then
        error "chsh command unsuccessful. Change your default shell manually."
    else
        green "=== Shell successfully changed to '$zsh' ==="
    fi

    echo "export TERM=xterm-256color" >> ${HOME}/.zshrc
    source ${HOME}/.zshrc
    green "oh-my-zsh 安装并配置成功, 若显示不正常请重新登陆服务器..."
}

install_zsh
install_oh_my_zsh