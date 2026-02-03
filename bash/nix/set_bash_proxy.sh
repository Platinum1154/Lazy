#!/bin/bash

BASHRC_FILE="$HOME/.bashrc"
START_MARK="# === PROXY_CONFIG_START (DO NOT EDIT) ==="
END_MARK="# === PROXY_CONFIG_END ==="

# 定义颜色方便后续修改
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# 1. 获取输入
read -p "请输入代理主机 IP (默认 127.0.0.1): " USER_HOST
USER_HOST=${USER_HOST:-127.0.0.1}  

read -p "请输入代理端口 (默认 7890): " USER_PORT
USER_PORT=${USER_PORT:-7890}

# 2. 备份文件
cp "$BASHRC_FILE" "${BASHRC_FILE}.bak"

# 3. 如果存在旧配置，先删除 (实现“修改”功能)
if grep -q "$START_MARK" "$BASHRC_FILE"; then
    echo " 检测到已有配置，正在更新 IP..."
    # 兼容 Mac 和 Linux 的 sed 删除
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/$START_MARK/,/$END_MARK/d" "$BASHRC_FILE"
    else
        sed -i "/$START_MARK/,/$END_MARK/d" "$BASHRC_FILE"
    fi
fi

# 4. 写入配置 (完全保留你的原始逻辑)
cat << EOF >> "$BASHRC_FILE"
$START_MARK
# -----------------------------------------------------------
# 代理配置区
# -----------------------------------------------------------
PROXY_HOST="$USER_HOST"
PROXY_PORT="$USER_PORT"

# 手动开关
alias proxy_off='unset http_proxy https_proxy all_proxy; echo " === 代理已关闭 === "'
alias proxy_on='export http_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"; export https_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"; echo " === 代理已强制开启 (IP: \${PROXY_HOST}) === "'

# 测试代理服务器连通性，超时时间为2秒。
if timeout 2 nc -z \$PROXY_HOST \$PROXY_PORT; then
    echo " === 代理服务器可用，设置代理 http://\${PROXY_HOST}:\${PROXY_PORT} === "
    export http_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"
    export https_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"
else
    echo " === 代理服务器不可用，取消所有代理 === "
    unset http_proxy
    unset https_proxy
fi
$END_MARK
EOF

echo " === 配置已更新。IP: $USER_HOST 端口: $USER_PORT === "

# 5. 自动生效
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    source "$BASHRC_FILE"
else
    echo "🔄 正在重新加载 Shell..."
    echo -e "   ${GREEN}proxy_on${NC}     强制开启代理 (IP: $USER_HOST)"
    echo -e "   ${RED}proxy_off${NC}    关闭所有代理"

    exec bash -l
fi