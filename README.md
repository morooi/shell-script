# Shell Script

记录并学习一些 Shell 脚本

- 快速安装 Trojan-go：[trojan-go-quickstart.sh](./trojan-go-quickstart.sh)
  
  ``` bash
  # 使用 root 用户运行，或添加 sudo
  wget -N --no-check-certificate "https://raw.githubusercontent.com/morooi/shell-script/master/trojan-go-quickstart.sh"
  chmod +x trojan-go-quickstart.sh
  ./trojan-go-quickstart.sh
  # 或
  bash <(wget -qO- https://raw.githubusercontent.com/morooi/shell-script/master/trojan-go-quickstart.sh)
  # 或
  bash <(curl -sL https://raw.githubusercontent.com/morooi/shell-script/master/trojan-go-quickstart.sh)
  ```

- 安装 zsh 和 oh-my-zsh：[install-zsh.sh](./install-zsh.sh)

  ``` bash
  wget -N --no-check-certificate "https://raw.githubusercontent.com/morooi/shell-script/master/install-zsh.sh"
  chmod +x install-zsh.sh
  ./install-zsh.sh
  # 或
  bash <(wget -qO- https://raw.githubusercontent.com/morooi/shell-script/master/install-zsh.sh)
  # 或
  bash <(curl -sL https://raw.githubusercontent.com/morooi/shell-script/master/install-zsh.sh)
  ```