#!/usr/bin/env python3
import os
from pathlib import Path
import platform
import stat
import subprocess
import sys
import urllib.request

# Target storage directory: ~/Documents/llamafile_models
STORAGE_DIR = Path.home() / "Documents" / "llamafile_models"


def get_system_specs():
    arch = platform.machine().lower()
    if arch in ["x86_64", "amd64"]:
        arch_type = "x86_64"
    elif arch in ["aarch64", "arm64"]:
        arch_type = "arm64"
    else:
        arch_type = "unsupported"

    total_ram_gb = 8.0
    try:
        with open("/proc/meminfo", "r") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    mem_kb = int(line.split()[1])
                    total_ram_gb = mem_kb / (1024 * 1024)
                    break
    except Exception:
        pass

    return arch_type, total_ram_gb


def select_model(total_ram_gb):
    if total_ram_gb < 7.0:
        model_name = "SmolLM2-1.7B-Instruct.Q4_K_M.llamafile"
        url = (
            "https://huggingface.co/Mozilla/SmolLM2-1.7B-Instruct-llamafile/"
            "resolve/main/SmolLM2-1.7B-Instruct.Q4_K_M.llamafile"
        )
        tag = "Lightweight model (~1.7B params, ~1.2 GB download)"
    elif total_ram_gb < 14.0:
        model_name = "Llama-3.2-3B-Instruct.Q4_K_M.llamafile"
        url = (
            "https://huggingface.co/Mozilla/Llama-3.2-3B-Instruct-llamafile/"
            "resolve/main/Llama-3.2-3B-Instruct.Q4_K_M.llamafile"
        )
        tag = "Balanced model (~3.2B params, ~2.2 GB download)"
    else:
        # Verified Hugging Face release file path
        model_name = "Meta-Llama-3-8B-Instruct.Q4_K_M.llamafile"
        url = (
            "https://huggingface.co/Mozilla/Meta-Llama-3-8B-Instruct-llamafile/"
            "resolve/main/Meta-Llama-3-8B-Instruct.Q4_K_M.llamafile"
        )
        tag = "Full 8B model (~8B params, ~4.9 GB download)"

    return model_name, url, tag


def download_with_progress(url, dest_path):
    print(f"Downloading from:\n{url}")

    # Set custom User-Agent to prevent Hugging Face CDN blocking
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"}
    )

    with urllib.request.urlopen(req) as response, open(dest_path, "wb") as out_file:
        total_size = int(response.headers.get("Content-Length", 0))
        downloaded = 0
        block_size = 1024 * 1024  # 1MB chunks

        while True:
            buffer = response.read(block_size)
            if not buffer:
                break
            downloaded += len(buffer)
            out_file.write(buffer)

            if total_size > 0:
                percent = int(downloaded * 100 / total_size)
                cur_mb = downloaded / (1024 * 1024)
                total_mb = total_size / (1024 * 1024)
                sys.stdout.write(
                    f"\rDownloading: {percent}% [{cur_mb:.1f} MB / {total_mb:.1f} MB]"
                )
                sys.stdout.flush()

    print("\nDownload complete.")


def main():
    arch, ram_gb = get_system_specs()
    print(f"Detected System: {arch} architecture | {ram_gb:.1f} GB RAM")

    if arch == "unsupported":
        print(f"Error: Architecture '{platform.machine()}' is not supported.")
        sys.exit(1)

    # Ensure ~/Documents/llamafile_models directory exists
    STORAGE_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Target folder: {STORAGE_DIR}")

    model_filename, download_url, description = select_model(ram_gb)
    target_path = STORAGE_DIR / model_filename

    print(f"Selected model: {description}")
    print(f"Saving to: {target_path}\n")

    if target_path.exists():
        print(f"'{model_filename}' already exists in {STORAGE_DIR}.")
    else:
        try:
            download_with_progress(download_url, target_path)
        except Exception as e:
            # Clean up partial download file if interrupted or failed
            if target_path.exists():
                target_path.unlink()
            print(f"\nDownload failed: {e}")
            sys.exit(1)

    # Make executable (chmod +x)
    print("Setting execution permissions (chmod +x)...")
    st = os.stat(target_path)
    os.chmod(target_path, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    # Run
    answer = input(f"\nLaunch {model_filename} now? (y/n): ").strip().lower()
    if answer in ["y", "yes"]:
        print(f"\nStarting server from: {STORAGE_DIR}")
        print("Navigate to: http://127.0.0.1:8080")
        print("Press Ctrl+C to terminate.")
        try:
            # llamafiles are Cosmopolitan "APE" polyglot binaries (part shell
            # script, part executable). Calling them directly via
            # subprocess.run bypasses any shell's ENOEXEC fallback handling
            # and can raise "OSError: [Errno 8] Exec format error" (this
            # also affects zsh < 5.9 when run interactively). Invoking
            # through `sh` avoids this reliably across shells/versions.
            subprocess.run(["sh", str(target_path)], cwd=str(STORAGE_DIR))
        except KeyboardInterrupt:
            print("\nShutting down.")


if __name__ == "__main__":
    main()