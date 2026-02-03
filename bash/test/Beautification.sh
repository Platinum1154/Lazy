# ==========================================
# 🎨 图标与显示配置模块
# ==========================================

# 1. 检测是否支持 UTF-8 (大部分现代终端都支持，不支持的老旧系统会回退)
if [[ "$LANG" == *"UTF-8"* ]] || [[ "$LC_ALL" == *"UTF-8"* ]]; then
    USE_EMOJI=true
else
    USE_EMOJI=false
fi

# 2. 定义图标集 (根据环境自动切换)
if [ "$USE_EMOJI" = true ]; then
    # Emoji 模式 (好看)
    IC_OK="✅"
    IC_ERR="❌"
    IC_WARN="⚠️ "
    IC_INFO="ℹ️ "
    IC_ROCKET="🚀"
    IC_STOP="🚫"
    IC_SEARCH="🔍"
    IC_LINK="🔗"
else
    # ASCII 模式 (兼容性最好，老古董机器也能看)
    IC_OK="[OK]"
    IC_ERR="[ERROR]"
    IC_WARN="[WARN]"
    IC_INFO="[INFO]"
    IC_ROCKET="[START]"
    IC_STOP="[STOP]"
    IC_SEARCH="[SCAN]"
    IC_LINK="[LINK]"
fi

# 定义颜色 (方便调用)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'