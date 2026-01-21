#!/bin/bash

BASHRC_FILE="$HOME/.bashrc"
START_MARK="# === PROXY_CONFIG_START (DO NOT EDIT) ==="
END_MARK="# === PROXY_CONFIG_END ==="

# 1. 获取输入 (带默认值)
read -p "请输入代理主机 IP (例如 192.168.1.204): " USER_HOST
read -p "请输入代理端口 (默认 7890): " USER_PORT
USER_PORT=${USER_PORT:-7890}

if [ -z "$USER_HOST" ]; then
    echo "❌ 错误: IP 不能为空"
    exit 1
fi

# 2. 备份文件
cp "$BASHRC_FILE" "${BASHRC_FILE}.bak"

# 3. 如果存在旧配置，先删除 (实现“修改”功能)
if grep -q "$START_MARK" "$BASHRC_FILE"; then
    echo "🔄 检测到已有配置，正在更新 IP..."
    # 兼容 Mac 和 Linux 的 sed 删除
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/$START_MARK/,/$END_MARK/d" "$BASHRC_FILE"
    else
        sed -i "/$START_MARK/,/$END_MARK/d" "$BASHRC_FILE"
    fi
fi

# 4. 写入配置 (完全保留你的原始逻辑)
# 注意：除了 $USER_HOST 和 $USER_PORT 是现在替换，
# 其他变量（如 $PROXY_HOST）我都加了反斜杠 \，确保它们原样写入 bashrc

cat << EOF >> "$BASHRC_FILE"
$START_MARK
# -----------------------------------------------------------
# 代理配置区
# -----------------------------------------------------------
PROXY_HOST="$USER_HOST"
PROXY_PORT="$USER_PORT"

# 手动开关
alias proxy_off='unset http_proxy https_proxy all_proxy; echo "🚫 代理已关闭"'
alias proxy_on='export http_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"; export https_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"; echo "✅ 代理已强制开启 (IP: \${PROXY_HOST})"'

# 测试代理服务器连通性，超时时间为5秒。
if (echo > /dev/tcp/\${PROXY_HOST}/\${PROXY_PORT}) &> /dev/null; then
    echo "🌐 代理服务器可用，设置代理 http://\${PROXY_HOST}:\${PROXY_PORT}"
    export http_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"
    export https_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"
else
    echo "⚠️ 代理服务器不可用，取消所有代理"
    unset http_proxy
    unset https_proxy
fi
$END_MARK
EOF

echo "✅ 配置已更新。IP: $USER_HOST 端口: $USER_PORT"

# 5. 自动生效
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    source "$BASHRC_FILE"
else
    echo "🔄 正在重新加载 Shell..."
    exec bash -l
fi