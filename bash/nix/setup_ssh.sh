#!/bin/bash

# 颜色定义，方便查看进度
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}>>> 开始自动化配置 SSH 服务...${NC}"

# 1. 更新系统软件包列表
echo -e "${BLUE}>>> 正在更新软件包列表...${NC}"
sudo apt update

# 2. 检查并安装 OpenSSH Server
if ! dpkg -s openssh-server >/dev/null 2>&1; then
    echo -e "${BLUE}>>> 检测到未安装 SSH，正在进行安装...${NC}"
    sudo apt install -y openssh-server openssh-sftp-server
else
    echo -e "${GREEN}>>> SSH 服务已安装，跳过安装步骤。${NC}"
fi

# 3. 启动并设置开机自启
echo -e "${BLUE}>>> 正在启动 SSH 服务并设置开机自启...${NC}"
sudo systemctl enable --now ssh

# 4. 检查服务状态
echo -e "${BLUE}>>> 检查服务运行状态:${NC}"
STATUS=$(systemctl is-active ssh)

if [ "$STATUS" = "active" ]; then
    echo -e "${GREEN}✅ SSH 服务已成功启动并运行！${NC}"
else
    echo -e "${BLUE}>>> 服务未正常运行，尝试重启...${NC}"
    sudo systemctl restart ssh
fi

# 5. 显示当前 IP 地址（方便远程连接）
echo -e "${BLUE}>>> 当前本机 IP 地址如下（请找寻类似 192.168.x.x）:${NC}"
hostname -I | awk '{print $1}'

echo -e "${GREEN}>>> 配置完成！你现在可以尝试从其他终端连接了。${NC}"