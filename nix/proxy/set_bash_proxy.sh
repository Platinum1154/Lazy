#!/bin/bash

BASHRC_FILE="$HOME/.bashrc"
START_MARK="# === AUTO_PROXY_CONFIG_START ==="
END_MARK="# === AUTO_PROXY_CONFIG_END ==="

# 1. 获取用户输入
read -p "请输入代理主机 IP (例如 192.168.1.204): " USER_HOST
read -p "请输入代理端口 (默认 7890): " USER_PORT
USER_PORT=${USER_PORT:-7890} 

if [ -z "$USER_HOST" ]; then
    echo "❌ 错误: IP 地址不能为空"
    exit 1
fi

# 2. 备份
cp "$BASHRC_FILE" "${BASHRC_FILE}.bak"

# 3. 清理旧配置 (如果有)
if grep -q "$START_MARK" "$BASHRC_FILE"; then
    echo "🔄 检测到旧配置，正在清理并更新..."
    # 兼容 Mac 和 Linux 的 sed 写法
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/$START_MARK/,/$END_MARK/d" "$BASHRC_FILE"
    else
        sed -i "/$START_MARK/,/$END_MARK/d" "$BASHRC_FILE"
    fi
fi

# 4. 写入新配置
# 注意：${PROXY_...} 前面的 \ 是为了让这些变量原样写入文件，而不是在脚本运行时被替换
cat << EOF >> "$BASHRC_FILE"
$START_MARK
# 代理服务器配置 (自动生成)
PROXY_HOST="$USER_HOST"
PROXY_PORT="$USER_PORT"

# 连通性测试 (超时 1 秒)
if command -v timeout &> /dev/null; then
    # Linux 方式
    CHECK_CMD="timeout 0.5 cat < /dev/null > /dev/tcp/\${PROXY_HOST}/\${PROXY_PORT}"
else
    # Mac/其它 方式 (没有 timeout 命令时简单的 nc 检测，或者是忽略超时控制)
    CHECK_CMD="nc -z -G 1 \${PROXY_HOST} \${PROXY_PORT}"
fi

if eval "\$CHECK_CMD" 2> /dev/null; then
    export http_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"
    export https_proxy="http://\${PROXY_HOST}:\${PROXY_PORT}"
    # echo "✅ 代理已自动连接"
else
    unset http_proxy
    unset https_proxy
    # echo "⚠️ 代理不通，已自动直连"
fi
$END_MARK
EOF

echo "✅ 配置已写入 .bashrc (IP: $USER_HOST:$USER_PORT)"

# ==========================================
# 5. 核心修改：让配置立即生效
# ==========================================

# 判断脚本是被 source 运行的，还是被直接执行的
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # 情况 A: 用户用了 "source ./script.sh"
    # 直接刷新环境即可
    source "$BASHRC_FILE"
    echo "⚡️ 环境变量已在当前终端刷新！"
else
    # 情况 B: 用户用了 "./script.sh" (最常见的情况)
    # 我们必须用 exec bash 替换当前 Shell 进程，来模拟“重启终端”的效果
    echo "🔄 正在重新加载 Shell 环境以使配置生效..."
    exec bash -l
fi