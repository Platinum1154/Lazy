import os
import ssl
import sys
import shutil
import zipfile
import urllib.request
from pathlib import Path

# ========================
# 配置
# ========================

FFMPEG_URLS = [
    "https://github.com/BtbN/FFmpeg-Builds/releases/download/"
    "autobuild-2024-02-01-12-55/ffmpeg-master-latest-win64-gpl.zip",

    "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip",
]

BASE_DIR = Path(__file__).resolve().parent
BIN_DIR = BASE_DIR / "bin"
ZIP_PATH = BASE_DIR / "ffmpeg.zip"


# ========================
# 工具函数
# ========================

def detect_proxy():
    proxies = {}
    for key in ("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY"):
        val = os.environ.get(key) or os.environ.get(key.lower())
        if val:
            proxies[key] = val
    return proxies


def download_with_progress(url: str, dest: Path):
    print("⬇️ 开始下载 ffmpeg")

    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    with urllib.request.urlopen(url, context=ctx) as response:
        total = response.length
        downloaded = 0
        chunk_size = 8192

        with open(dest, "wb") as f:
            while True:
                chunk = response.read(chunk_size)
                if not chunk:
                    break

                f.write(chunk)
                downloaded += len(chunk)

                if total:
                    percent = downloaded / total * 100
                    mb_done = downloaded / 1024 / 1024
                    mb_total = total / 1024 / 1024
                    print(
                        f"\r📦 {percent:6.2f}% "
                        f"({mb_done:6.1f} / {mb_total:6.1f} MB)",
                        end="",
                        flush=True,
                    )

    print("\n✅ 下载完成")


def extract_ffmpeg(zip_path: Path, target_dir: Path):
    print("📂 解压 ffmpeg...")

    with zipfile.ZipFile(zip_path, "r") as z:
        z.extractall(target_dir)

    # 找 ffmpeg.exe
    for exe in target_dir.rglob("ffmpeg.exe"):
        final_path = BIN_DIR / "ffmpeg.exe"
        BIN_DIR.mkdir(exist_ok=True)
        shutil.copy(exe, final_path)
        print(f"✅ ffmpeg 已安装到: {final_path}")
        return

    raise RuntimeError("❌ 解压完成，但未找到 ffmpeg.exe")


# ========================
# 主流程
# ========================

def main():
    print("🔍 检查代理状态...")
    proxies = detect_proxy()

    if proxies:
        print("🌐 检测到代理环境：")
        for k, v in proxies.items():
            print(f"   {k} = {v}")
    else:
        print("🌐 未检测到代理")

    if BIN_DIR.exists() and (BIN_DIR / "ffmpeg.exe").exists():
        print("✅ ffmpeg 已存在，跳过安装")
        return

    if ZIP_PATH.exists():
        ZIP_PATH.unlink()

    for url in FFMPEG_URLS:
        try:
            download_with_progress(url, ZIP_PATH)
            break
        except Exception as e:
            print(f"⚠️ 下载失败，尝试下一个源\n   {e}")
    else:
        raise RuntimeError("❌ 所有 ffmpeg 下载源均失败")
    extract_ffmpeg(ZIP_PATH, BASE_DIR)

    print("🎉 ffmpeg 安装完成，可以直接在项目里用了")


if __name__ == "__main__":
    main()