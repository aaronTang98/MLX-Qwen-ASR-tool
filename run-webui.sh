#!/bin/bash

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# 错误处理函数
error_exit() {
    echo -e "${RED}❌ 错误：$1${NC}"
    exit 1
}

# 信息输出函数
echo_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 检查虚拟环境
if [ ! -d ~/mlx-qwen3-asr/venv ]; then
    error_exit "虚拟环境不存在，请先运行 ./install.sh 安装 MLX-Qwen3-ASR"
fi

# 激活虚拟环境
echo_info "激活虚拟环境..."
cd ~/mlx-qwen3-asr && source venv/bin/activate

# 检查依赖
echo_info "检查 WebUI 依赖..."
python -c "import fastapi" 2>/dev/null
if [ $? -ne 0 ]; then
    echo_warning "缺少 fastapi 和 uvicorn，正在安装..."
    pip install fastapi uvicorn python-multipart -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
    if [ $? -ne 0 ]; then
        error_exit "依赖安装失败"
    fi
fi

python -c "import uvicorn" 2>/dev/null
if [ $? -ne 0 ]; then
    echo_warning "缺少 uvicorn，正在安装..."
    pip install uvicorn -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
    if [ $? -ne 0 ]; then
        error_exit "依赖安装失败"
    fi
fi

python -c "import python_multipart" 2>/dev/null
if [ $? -ne 0 ]; then
    echo_warning "缺少 python-multipart，正在安装..."
    pip install python-multipart -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
    if [ $? -ne 0 ]; then
        error_exit "依赖安装失败"
    fi
fi

echo_success "依赖检查完成"

# 设置 Hugging Face 国内镜像
export HF_ENDPOINT=https://hf-mirror.com
echo_info "使用 Hugging Face 国内镜像: $HF_ENDPOINT"

# 启动服务器
echo ""
echo_success "🚀 启动 MLX-Qwen3-ASR WebUI"
echo "====================================="
echo_info "Web 服务将在 http://localhost:8000 启动"
echo_info "请在浏览器中打开上述地址"
echo "====================================="
echo ""

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ ! -d "$SCRIPT_DIR/webui" ]; then
    error_exit "webui目录不存在，请确保项目结构完整"
fi
cd "$SCRIPT_DIR/webui"
$(which python) server.py
