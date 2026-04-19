"""
MLX-Qwen3-ASR WebUI 后端
基于 FastAPI 的轻量级后端，接收音频文件并调用 MLX-Qwen3-ASR 进行语音识别
"""

import os
import asyncio
import subprocess
import tempfile
import time
from typing import Optional
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

app = FastAPI(title="MLX-Qwen3-ASR WebUI", description="本地语音识别 Web 界面")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TranscribeResponse(BaseModel):
    success: bool
    text: Optional[str] = None
    error: Optional[str] = None
    time_used: float = 0.0

def check_model_exists(model_name: str) -> bool:
    """检查模型是否已经下载完成"""
    model_slug = "models--" + model_name.replace("/", "--")
    model_dir = os.path.expanduser(f"~/.cache/huggingface/hub/{model_slug}")
    print(f"[DEBUG] 检查模型路径: {model_dir}")
    print(f"[DEBUG] 模型目录存在: {os.path.exists(model_dir)}")
    exists = os.path.exists(model_dir)
    return exists

@app.get("/api/status")
async def get_status():
    """获取模型状态"""
    models = {
        "Qwen/Qwen3-ASR-0.6B": check_model_exists("Qwen/Qwen3-ASR-0.6B"),
        "Qwen/Qwen3-ASR-1.7B": check_model_exists("Qwen/Qwen3-ASR-1.7B"),
    }
    return {"success": True, "models": models}

@app.post("/api/transcribe", response_model=TranscribeResponse)
async def transcribe_audio(
    file: UploadFile = File(...),
    model: str = "Qwen/Qwen3-ASR-0.6B",
    with_timestamps: bool = False
):
    """上传音频文件并进行语音识别"""
    start_time = time.time()
    
    # 检查模型是否存在
    if not check_model_exists(model):
        error_msg = f"模型 {model} 未下载，请先运行 ./download_models.sh 下载模型"
        return TranscribeResponse(
            success=False,
            error=error_msg,
            time_used=time.time() - start_time
        )
    
    # 创建临时文件保存上传的音频
    suffix = os.path.splitext(file.filename)[1]
    if not suffix:
        suffix = ".wav"
    
    try:
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
            tmp.write(await file.read())
            temp_file_path = tmp.name
    except Exception as e:
        return TranscribeResponse(
            success=False,
            error=f"保存临时文件失败: {str(e)}",
            time_used=time.time() - start_time
        )
    
    try:
        # 激活虚拟环境并运行 mlx-qwen3-asr
        # 使用环境变量中的 HF_ENDPOINT
        venv_path = os.path.expanduser("~/mlx-qwen3-asr/venv/bin/activate")
        script_path = os.path.abspath(__file__)
        project_dir = os.path.dirname(os.path.dirname(script_path))
        
        # 构建命令
        cmd_parts = [
            "source", os.path.expanduser("~/mlx-qwen3-asr/venv/bin/activate"),
            "&&",
            "python", "-m", "mlx_qwen3_asr",
            "--model", model,
        ]
        
        if with_timestamps:
            cmd_parts.append("--timestamps")
        
        cmd_parts.append(temp_file_path)
        
        # 运行命令
        result = subprocess.run(
            " ".join(cmd_parts),
            shell=True,
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            return TranscribeResponse(
                success=False,
                error=f"识别失败: {result.stderr}",
                time_used=time.time() - start_time
            )
        
        # 获取识别结果
        # mlx-qwen3-asr 会将结果输出到 stdout
        text = result.stdout.strip()
        
        return TranscribeResponse(
            success=True,
            text=text,
            time_used=time.time() - start_time
        )
        
    finally:
        # 清理临时文件
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)

# 挂载静态文件
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    app.mount("/", StaticFiles(directory=static_dir, html=True), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
