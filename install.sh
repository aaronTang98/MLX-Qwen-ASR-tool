#!/bin/bash

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

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

# 检查系统架构
check_system() {
    echo_info "检查系统架构..."
    ARCH=$(uname -m)
    if [[ "$ARCH" != "arm64" ]]; then
        echo_warning "警告：本脚本针对 Apple Silicon 芯片优化，当前架构为 $ARCH"
    else
        # 检测具体芯片型号
        CHIP=$(sysctl -n machdep.cpu.brand_string | grep -o "M[0-9]")
        if [[ "$CHIP" == "M4" ]]; then
            echo_success "检测到 M4 芯片，将进行特定优化"
        else
            echo_info "检测到 $CHIP 芯片"
        fi
    fi
}

# 检查 macOS 版本
check_macos_version() {
    echo_info "检查 macOS 版本..."
    MACOS_VERSION=$(sw_vers -productVersion)
    MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)
    if [[ $MACOS_MAJOR -lt 14 ]]; then
        echo_warning "警告：推荐使用 macOS 14.0+ (Sonoma) 以获得最佳性能"
    else
        echo_success "macOS 版本符合要求：$MACOS_VERSION"
    fi
}

# 安装 Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo_info "正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -ne 0 ]; then
            echo_warning "Homebrew 安装失败，尝试使用国内镜像..."
            /bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
            if [ $? -ne 0 ]; then
                error_exit "Homebrew 安装失败，请检查网络连接"
            fi
        fi
        # 刷新环境变量
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo_success "Homebrew 已安装"
        # 更新 Homebrew
        echo_info "更新 Homebrew..."
        brew update
    fi
}

# 安装依赖
install_dependencies() {
    echo_info "安装 Python 3.12 和 ffmpeg..."
    brew install python@3.12 ffmpeg
    if [ $? -ne 0 ]; then
        error_exit "依赖安装失败"
    fi
    echo_success "依赖安装完成"
}

# 创建工作目录
create_workspace() {
    echo_info "创建工作目录..."
    mkdir -p ~/mlx-qwen3-asr
    cd ~/mlx-qwen3-asr || error_exit "无法进入工作目录"
    echo_success "工作目录创建完成"
}

# 创建虚拟环境
create_venv() {
    echo_info "创建虚拟环境..."
    if [ -d "venv" ]; then
        echo_warning "虚拟环境已存在，重新创建..."
        rm -rf venv
    fi
    python3.12 -m venv venv
    if [ $? -ne 0 ]; then
        error_exit "虚拟环境创建失败"
    fi
    source venv/bin/activate
    echo_success "虚拟环境创建完成"
}

# 安装 MLX-Qwen3-ASR
install_mlx_qwen3_asr() {
    echo_info "安装 MLX Qwen3-ASR..."
    
    # 尝试使用国内镜像源
    PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
    
    # 升级 pip
    echo_info "升级 pip..."
    pip install --upgrade pip -i $PIP_MIRROR --trusted-host pypi.tuna.tsinghua.edu.cn
    if [ $? -ne 0 ]; then
        echo_warning "pip 升级失败，尝试使用默认源..."
        pip install --upgrade pip
        if [ $? -ne 0 ]; then
            error_exit "pip 升级失败"
        fi
    fi
    
    # 针对 M4 芯片的优化安装
    if [[ "$CHIP" == "M4" ]]; then
        echo_info "为 M4 芯片优化安装..."
        pip install -U mlx mlx-qwen3-asr -i $PIP_MIRROR --trusted-host pypi.tuna.tsinghua.edu.cn
        if [ $? -ne 0 ]; then
            echo_warning "使用镜像源安装失败，尝试使用默认源..."
            pip install -U mlx mlx-qwen3-asr
            if [ $? -ne 0 ]; then
                error_exit "MLX Qwen3-ASR 安装失败"
            fi
        fi
    else
        pip install -U mlx mlx-qwen3-asr -i $PIP_MIRROR --trusted-host pypi.tuna.tsinghua.edu.cn
        if [ $? -ne 0 ]; then
            echo_warning "使用镜像源安装失败，尝试使用默认源..."
            pip install -U mlx mlx-qwen3-asr
            if [ $? -ne 0 ]; then
                error_exit "MLX Qwen3-ASR 安装失败"
            fi
        fi
    fi
    
    echo_success "MLX Qwen3-ASR 安装完成"
}

# 配置快捷命令
configure_alias() {
    echo_info "配置快捷命令..."
    # 检查 .zshrc 文件是否存在
    if [ ! -f ~/.zshrc ]; then
        touch ~/.zshrc
    fi
    # 移除已存在的 alias 和函数
    sed -i '' '/alias asr=/d' ~/.zshrc
    sed -i '' '/^asr()/,/^}/d' ~/.zshrc
    sed -i '' '/^mlxasr()/,/^}/d' ~/.zshrc
    # 添加新的函数（使用 mlxasr 而不是 asr，避免与系统命令冲突）
    cat >> ~/.zshrc << 'EOF'

# MLX-Qwen3-ASR 快捷命令
mlxasr() {
    local CURRENT_DIR=$(pwd)
    cd ~/mlx-qwen3-asr && source venv/bin/activate
    cd "$CURRENT_DIR"
    python ~/mlx-qwen3-asr/venv/bin/mlx-qwen3-asr "$@"
}
EOF
    # 刷新环境变量
    source ~/.zshrc
    echo_success "快捷命令配置完成"
}

# 预下载默认模型
pre_download_model() {
    echo ""
    echo_info "正在预下载默认模型 Qwen/Qwen3-ASR-0.6B..."
    echo_info "模型大小约 1.2GB，首次下载需要一些时间，请耐心等待..."
    echo "下载过程中会显示进度，请耐心等待..."
    echo ""
    
    # 创建缓存目录
    local cache_parent=~/.cache/huggingface
    local cache_dir=~/.cache/huggingface/hub
    
    if [ ! -d "$cache_parent" ]; then
        echo_info "创建缓存目录 $cache_parent"
        mkdir -p "$cache_parent"
    fi
    
    if [ ! -d "$cache_dir" ]; then
        echo_info "创建缓存目录 $cache_dir"
        mkdir -p "$cache_dir"
    fi
    
    # 激活虚拟环境并预下载模型
    cd ~/mlx-qwen3-asr && source venv/bin/activate
    
    # 设置 Hugging Face 使用国内镜像
    export HF_ENDPOINT=https://hf-mirror.com
    
    # 创建一个空的临时文件用于触发下载
    # 只有提供音频文件才会触发模型下载，所以我们用空文件触发下载后立即删除
    echo "" > /tmp/mlx_qwen3_asr_empty_audio.wav
    
    # 触发模型下载 - 必须提供音频文件才会触发下载
    # 下载完成后程序会退出，我们删除临时文件
    python -m mlx_qwen3_asr --model Qwen/Qwen3-ASR-0.6B /tmp/mlx_qwen3_asr_empty_audio.wav
    rm -f /tmp/mlx_qwen3_asr_empty_audio.wav
    
    # 检查模型是否真的下载完成
    local model_dir=~/.cache/huggingface/hub/models--Qwen--Qwen3-ASR-0.6B
    if [ -d "$model_dir" ] && [ -d "$model_dir/blobs" ] && [ -n "$(ls -A $model_dir/blobs 2>/dev/null)" ]; then
        echo_success "默认模型预下载完成！"
    else
        echo_warning "默认模型预下载可能未完成"
        echo_warning "安装完成后请运行 ./download_models.sh 重新下载"
    fi
}

# 询问是否预下载 1.7B 模型
ask_download_1_7b() {
    echo ""
    read -p "是否预下载更大更精准的模型 Qwen/Qwen3-ASR-1.7B？(约 3.4GB) (y/N): " download_1_7b
    
    if [[ "$download_1_7b" =~ ^[Yy]$ ]]; then
        echo_info "正在预下载 Qwen/Qwen3-ASR-1.7B..."
        echo_info "模型大小约 3.4GB，下载需要一些时间，请耐心等待..."
        echo "下载过程中会显示进度，请耐心等待..."
        echo ""
        
        # 设置 Hugging Face 使用国内镜像
        export HF_ENDPOINT=https://hf-mirror.com
        
        # 创建一个空的临时文件用于触发下载
        # 只有提供音频文件才会触发模型下载，所以我们用空文件触发下载后立即删除
        echo "" > /tmp/mlx_qwen3_asr_empty_audio.wav
        
        # 触发模型下载 - 必须提供音频文件才会触发下载
        # 下载完成后程序会退出，我们删除临时文件
        python -m mlx_qwen3_asr --model Qwen/Qwen3-ASR-1.7B /tmp/mlx_qwen3_asr_empty_audio.wav
        rm -f /tmp/mlx_qwen3_asr_empty_audio.wav
        
        # 检查模型是否真的下载完成
        local model_dir=~/.cache/huggingface/hub/models--Qwen--Qwen3-ASR-1.7B
        if [ -d "$model_dir" ] && [ -d "$model_dir/blobs" ] && [ -n "$(ls -A $model_dir/blobs 2>/dev/null)" ]; then
            echo_success "1.7B 模型预下载完成！"
        else
            echo_warning "1.7B 模型预下载可能未完成"
            echo_warning "安装完成后请运行 ./download_models.sh 重新下载"
        fi
    else
        echo_info "跳过 1.7B 模型预下载，首次使用时会自动下载"
    fi
}

# 显示安装完成信息
show_completion() {
    echo ""
    echo "====================================="
    echo_success "安装完成！"
    echo ""
    echo_success "📋 模型下载状态："
    echo "   ✅ 默认模型 Qwen/Qwen3-ASR-0.6B 已预下载"
    if [[ "$download_1_7b" =~ ^[Yy]$ ]]; then
        echo "   ✅ 精准模型 Qwen/Qwen3-ASR-1.7B 已预下载"
    else
        echo "   ℹ️  精准模型 Qwen/Qwen3-ASR-1.7B 未下载，使用时会自动下载"
    fi
    echo ""
    echo_success "🚀 现在可以开始使用了："
    echo "   基础转写：mlxasr 你的音频.mp3"
    echo "   保存到文件：mlxasr 录音.mp3 > 笔记.txt"
    echo "   带时间戳：mlxasr 录音.mp3 --timestamps > 笔记.txt"
    echo "   使用 1.7B：mlxasr 录音.mp3 --model Qwen/Qwen3-ASR-1.7B"
    echo ""
    echo_info "详细使用说明请查看 quickStart.md 文件"
    echo "====================================="
}

# 主函数
main() {
    echo ""
    echo "🚀 MLX-Qwen3-ASR 安装脚本（M4芯片优化版）"
    echo "====================================="
    
    # 检查系统
    check_system
    check_macos_version
    
    # 安装 Homebrew
    install_homebrew
    
    # 安装依赖
    install_dependencies
    
    # 创建工作目录
    create_workspace
    
    # 创建虚拟环境
    create_venv
    
    # 安装 MLX-Qwen3-ASR
    install_mlx_qwen3_asr
    
    # 配置快捷命令
    configure_alias
    
    # 预下载默认模型
    pre_download_model
    
    # 询问是否预下载 1.7B 模型
    ask_download_1_7b
    
    # 显示完成信息
    show_completion
}

# 执行主函数
main