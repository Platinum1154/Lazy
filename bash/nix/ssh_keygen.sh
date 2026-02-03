#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

# 1. 菜单选择
echo -e "${BLUE}=== SSH 密钥配置工具 ===${NC}"
echo "请选择你要配置的平台："
echo "1) GitHub (github.com)"
echo "2) Gitee  (gitee.com)"
echo "3) 自定义 (其他平台)"
read -p "请输入数字 [1-3]: " choice

case $choice in
    1)
        PLATFORM="GitHub"
        HOST_DOMAIN="github.com"
        DEFAULT_FILENAME="id_rsa_github"
        ;;
    2)
        PLATFORM="Gitee"
        HOST_DOMAIN="gitee.com"
        DEFAULT_FILENAME="id_rsa_gitee"
        ;;
    3)
        PLATFORM="Custom"
        read -p "请输入平台域名 (例如 gitlab.com): " HOST_DOMAIN
        if [ -z "$HOST_DOMAIN" ]; then echo "域名不能为空"; exit 1; fi
        DEFAULT_FILENAME="id_rsa_custom"
        ;;
    *)
        echo "❌ 无效选项，退出。"
        exit 1
        ;;
esac

echo -e "\n${GREEN}>>> 正在配置: $PLATFORM ($HOST_DOMAIN)${NC}"

# 2. 获取邮箱
read -p "请输入注册邮箱 (用于 -C 注释): " email
if [ -z "$email" ]; then
    echo "❌ 邮箱不能为空"
    exit 1
fi

# 3. 获取文件名 (支持自定义)
read -p "请输入密钥文件名 (默认为 $DEFAULT_FILENAME): " filename
if [ -z "$filename" ]; then
    filename=$DEFAULT_FILENAME
fi

# 确保 .ssh 目录存在
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

KEY_PATH="$SSH_DIR/$filename"

# 4. 检查文件是否已存在
if [ -f "$KEY_PATH" ]; then
    echo -e "${BLUE}⚠️  文件 $filename 已存在。${NC}"
    read -p "是否覆盖？(y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        echo "已取消操作。"
        exit 0
    fi
    rm "$KEY_PATH" "$KEY_PATH.pub" 2>/dev/null
    # 同时从 config 中清理旧的记录（可选，这里简单起见只追加）
fi

# 5. 生成密钥 (无密码模式)
echo -e "正在生成密钥..."
ssh-keygen -t rsa -C "$email" -f "$KEY_PATH" -N ""

# 6. 配置 ~/.ssh/config
# 先检查 config 是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

# 检查 config 中是否已经配置过这个域名，避免重复堆叠
# 注意：这只是一个简单的检查，如果想完美管理建议手动查看 config
if grep -q "Host $HOST_DOMAIN" "$CONFIG_FILE"; then
    echo -e "${BLUE}ℹ️  检测到 config 中已有 $HOST_DOMAIN 的配置。${NC}"
    echo "建议手动检查 ~/.ssh/config 确保 IdentityFile 指向正确。"
    echo "新密钥路径为: $KEY_PATH"
else
    # 写入配置
    echo -e "\n正在写入配置文件..."
    cat << EOF >> "$CONFIG_FILE"

# $PLATFORM ($email)
Host $HOST_DOMAIN
    HostName $HOST_DOMAIN
    User git
    IdentityFile $KEY_PATH
EOF
    echo "✅ Config 配置已更新。"
fi

# 7. 添加到 ssh-agent
echo -e "\n正在添加到 ssh-agent..."
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$KEY_PATH"

# 8. 输出公钥
echo -e "\n${GREEN}=== 配置完成！请复制下方公钥内容 ===${NC}"
echo "----------------------------------------------------------------"
cat "$KEY_PATH.pub"
echo "----------------------------------------------------------------"
echo -e "👉 添加地址: "
if [ "$PLATFORM" == "GitHub" ]; then
    echo "https://github.com/settings/keys"
elif [ "$PLATFORM" == "Gitee" ]; then
    echo "https://gitee.com/profile/sshkeys"
fi