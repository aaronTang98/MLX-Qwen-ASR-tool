# MLX-Qwen3-ASR 故障排除指南

本文档提供了 MLX-Qwen3-ASR 安装和使用过程中常见问题的解决方案。

## 一、安装问题

### 1. Homebrew 安装失败

**症状**：
- 安装脚本执行时显示 Homebrew 安装失败
- 网络连接超时
- 权限错误

**解决方案**：

1. **检查网络连接**
   - 确保网络连接正常
   - 尝试使用手机热点

2. **使用国内镜像**
   ```bash
   # 使用 Gitee 镜像安装 Homebrew
   /bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
   ```

3. **手动安装 Homebrew**
   ```bash
   # 克隆 Homebrew 仓库
   git clone https://mirrors.ustc.edu.cn/brew.git ~/.linuxbrew
   
   # 添加环境变量
   echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >> ~/.zshrc
   echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"' >> ~/.zshrc
   source ~/.zshrc
   ```

### 2. Python 版本问题

**症状**：
- 安装脚本显示 Python 版本不兼容
- 虚拟环境创建失败
- pip 命令不存在

**解决方案**：

1. **检查 Python 版本**
   ```bash
   python3 --version
   # 应该显示 Python 3.12+ 
   ```

2. **安装正确版本的 Python**
   ```bash
   brew install python@3.12
   
   # 确保使用正确的 Python 版本
   echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **修复 Python 链接**
   ```bash
   # 重新链接 Python
   brew unlink python && brew link python@3.12 --force
   ```

### 3. 权限错误

**症状**：
- 安装过程中显示权限被拒绝
- 无法创建目录或文件
- 无法写入 .zshrc 文件

**解决方案**：

1. **修复目录权限**
   ```bash
   # 修复工作目录权限
   sudo chown -R $USER ~/mlx-qwen3-asr
   
   # 修复 Homebrew 权限
   sudo chown -R $USER /opt/homebrew
   ```

2. **以管理员身份运行**
   ```bash
   # 使用 sudo 运行安装脚本
   sudo bash install.sh
   ```

3. **检查 .zshrc 文件权限**
   ```bash
   # 确保 .zshrc 文件可写
   chmod 644 ~/.zshrc
   ```

### 4. 依赖安装失败

**症状**：
- ffmpeg 安装失败
- 其他依赖包安装失败
- 编译错误

**解决方案**：

1. **更新 Homebrew**
   ```bash
   brew update
   brew upgrade
   ```

2. **单独安装依赖**
   ```bash
   # 单独安装 ffmpeg
   brew install ffmpeg
   
   # 单独安装 Python
   brew install python@3.12
   ```

3. **清理缓存**
   ```bash
   # 清理 Homebrew 缓存
   brew cleanup
   
   # 清理 pip 缓存
   pip cache purge
   ```

## 二、运行问题

### 1. 模型下载失败

**症状**：
- 首次运行时模型下载失败
- 网络连接超时
- 模型文件损坏

**解决方案**：

1. **检查网络连接**
   - 确保网络连接正常
   - 尝试使用 VPN

2. **手动下载模型**
   - 访问 Hugging Face：https://huggingface.co/mlx-community
   - 下载对应模型到 `~/.cache/huggingface/hub` 目录

3. **设置代理**
   ```bash
   # 设置 HTTP 代理
   export http_proxy=http://proxy.example.com:8080
   export https_proxy=http://proxy.example.com:8080
   
   # 运行 ASR 命令
   mlxasr 录音.mp3
   ```

### 2. 音频文件无法识别

**症状**：
- 命令执行后无输出
- 显示文件格式不支持
- 显示解码错误

**解决方案**：

1. **检查文件格式**
   ```bash
   # 检查文件信息
   file 你的录音文件.mp3
   
   # 检查音频信息
   ffmpeg -i 你的录音文件.mp3
   ```

2. **转换音频格式**
   ```bash
   # 转换为 WAV 格式
   ffmpeg -i 原文件.mp3 -ac 1 -ar 16000 转换后文件.wav
   
   # 使用转换后的文件
   mlxasr 转换后文件.wav
   ```

3. **检查文件权限**
   ```bash
   # 确保文件可读
   chmod 644 你的录音文件.mp3
   ```

### 3. 内存不足错误

**症状**：
- 运行时显示内存不足
- 程序崩溃
- 系统卡顿

**解决方案**：

1. **使用更小的模型**
   ```bash
   # 使用 0.5B 模型（默认）
   mlxasr 录音.mp3 --model mlx-community/Qwen3-ASR-0.5B
   ```

2. **调整 chunk 大小**
   ```bash
   # 减小处理块大小
   mlxasr 长音频.mp3 --chunk-size 5
   ```

3. **关闭其他应用**
   - 关闭不需要的应用程序
   - 释放系统内存

### 4. 命令未找到

**症状**：
- 执行 `asr` 命令时显示 "command not found"
- 快捷命令未生效

**解决方案**：

1. **重新加载配置文件**
   ```bash
   # 重新加载 .zshrc
   source ~/.zshrc
   ```

2. **检查 alias 配置**
   ```bash
   # 检查 alias 是否正确配置
   cat ~/.zshrc | grep asr
   ```

3. **手动执行命令**
   ```bash
   # 手动激活虚拟环境并运行
   cd ~/mlx-qwen3-asr && source venv/bin/activate && mlx-qwen3-asr transcribe 录音.mp3
   ```

## 三、性能问题

### 1. 识别速度慢

**症状**：
- 处理时间过长
- 系统资源占用高
- 大文件处理困难

**解决方案**：

1. **使用更小的模型**
   ```bash
   # 使用 0.5B 模型
   mlxasr 录音.mp3 --model mlx-community/Qwen3-ASR-0.5B
   ```

2. **调整线程数**
   ```bash
   # 增加线程数（M4芯片推荐 8）
   mlxasr 录音.mp3 --num-threads 8
   ```

3. **调整 chunk 大小**
   ```bash
   # 增大 chunk 大小（适合高性能机器）
   mlxasr 录音.mp3 --chunk-size 60
   ```

### 2. 识别准确率低

**症状**：
- 识别结果与实际内容不符
- 出现错别字
- 漏识别或误识别

**解决方案**：

1. **使用更大的模型**
   ```bash
   # 使用 1.7B 模型
   mlxasr 录音.mp3 --model mlx-community/Qwen3-ASR-1.7B
   ```

2. **调整 beam size**
   ```bash
   # 增大 beam size
   mlxasr 录音.mp3 --beam-size 5
   ```

3. **提高音频质量**
   - 确保录音环境安静
   - 使用高质量麦克风
   - 避免背景噪音

### 3. M4 芯片性能未充分利用

**症状**：
- M4 芯片性能未达到预期
- 处理速度与其他芯片差异不大

**解决方案**：

1. **更新系统**
   - 确保 macOS 为最新版本
   - 安装最新的系统更新

2. **优化参数**
   ```bash
   # M4 芯片优化参数
   mlxasr 录音.mp3 --num-threads 8 --chunk-size 30
   ```

3. **检查系统资源**
   - 确保没有其他占用大量资源的应用
   - 关闭系统节能模式

## 四、其他问题

### 1. 虚拟环境激活失败

**症状**：
- 无法激活虚拟环境
- 显示 "No such file or directory"

**解决方案**：

1. **检查虚拟环境目录**
   ```bash
   # 检查虚拟环境是否存在
   ls -la ~/mlx-qwen3-asr/venv
   ```

2. **重新创建虚拟环境**
   ```bash
   # 删除旧的虚拟环境
   rm -rf ~/mlx-qwen3-asr/venv
   
   # 重新创建
   cd ~/mlx-qwen3-asr && python3.12 -m venv venv
   source venv/bin/activate
   ```

### 2. 批量处理失败

**症状**：
- 批量处理时部分文件失败
- 输出目录创建失败
- 文件名包含特殊字符

**解决方案**：

1. **创建输出目录**
   ```bash
   # 手动创建输出目录
   mkdir -p 转写结果
   ```

2. **处理文件名**
   - 确保文件名不包含特殊字符
   - 使用英文文件名

3. **逐个处理文件**
   ```bash
   # 逐个处理文件
   for file in *.mp3; do
       mlxasr "$file" --output "转写结果/${file%.mp3}.txt"
   done
   ```

### 3. 时间戳格式问题

**症状**：
- 时间戳格式不正确
- 时间戳与实际内容不匹配

**解决方案**：

1. **调整时间戳格式**
   ```bash
   # 使用标准时间戳格式
   mlxasr 录音.mp3 --timestamps --output 带时间戳.txt
   ```

2. **检查音频文件**
   - 确保音频文件时长正确
   - 检查音频编码格式

## 五、高级故障排除

### 1. 查看详细日志

```bash
# 启用详细日志
asr 录音.mp3 --verbose

# 保存日志到文件
asr 录音.mp3 --verbose > debug.log 2>&1
```

### 2. 检查系统信息

```bash
# 检查系统架构
uname -m

# 检查 macOS 版本
sw_vers -productVersion

# 检查内存使用情况
top -l 1 | grep PhysMem

# 检查 CPU 信息
sysctl -n machdep.cpu.brand_string
```

### 3. 重新安装

如果以上方法都无法解决问题，可以尝试重新安装：

```bash
# 使用卸载脚本清理
./uninstall.sh

# 重新运行安装脚本
cd MLX-Qwen-ASR-tool
chmod +x install.sh
./install.sh
```

### 4. 手动清理（如果卸载脚本无法运行）

如果卸载脚本无法运行，可以手动清理：

```bash
# 删除工作目录
rm -rf ~/mlx-qwen3-asr

# 清理 .zshrc 中的配置
sed -i '' '/alias asr=/d' ~/.zshrc
sed -i '' '/^mlxasr()/,/^}/d' ~/.zshrc
sed -i '' '/^asr()/,/^}/d' ~/.zshrc
sed -i '' '/# MLX-Qwen3-ASR 快捷命令/d' ~/.zshrc

# 重新加载配置
source ~/.zshrc
```

## 六、联系支持

如果遇到无法解决的问题，可以通过以下方式获取支持：

1. **GitHub Issues**：在 [mlx-community/mlx-qwen3-asr](https://github.com/mlx-community/mlx-qwen3-asr) 提交 Issue

2. **技术社区**：加入相关技术社区交流

3. **本地调试**：
   - 检查系统日志
   - 查看 Python 错误信息
   - 尝试不同的音频文件

---

**提示**：大多数问题都可以通过上述方法解决。如果问题仍然存在，建议检查系统环境和网络连接，或尝试在不同的环境中测试。
