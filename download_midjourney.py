#!/usr/bin/env python3
"""
Midjourney Image Downloader
Usage:
    python3 download_midjourney.py <JOB_ID_OR_URL>
"""

import sys
import os
import re
from curl_cffi import requests

def extract_job_id(input_str: str) -> str:
    # Match UUID v4 pattern in URL or raw ID
    match = re.search(r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}', input_str, re.IGNORECASE)
    if match:
        return match.group(0)
    return input_str.strip()

def download_midjourney_job(job_id_or_url: str, output_dir: str = "."):
    job_id = extract_job_id(job_id_or_url)
    print(f"Downloading full images for Midjourney Job ID: {job_id}")

    os.makedirs(output_dir, exist_ok=True)
    downloaded_files = []

    # Midjourney grid indices 0..3
    for index in range(4):
        found = False
        for ext in ['png', 'jpeg']:
            url = f"https://cdn.midjourney.com/{job_id}/0_{index}.{ext}"
            try:
                r = requests.get(url, impersonate="chrome120")
                if r.status_code == 200 and len(r.content) > 10000 and not r.content.startswith(b"<!DOCTYPE"):
                    filename = os.path.join(output_dir, f"midjourney_{job_id}_{index}.{ext}")
                    with open(filename, "wb") as f:
                        f.write(r.content)
                    print(f"  [✓] Index {index}: Saved {filename} ({len(r.content):,} bytes)")
                    downloaded_files.append(filename)
                    found = True
                    break
            except Exception as e:
                print(f"  [!] Index {index} error ({ext}): {e}")

        if not found:
            print(f"  [✕] Index {index}: Could not retrieve full image.")

    return downloaded_files

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 download_midjourney.py <JOB_ID_OR_URL>")
        sys.exit(1)

    input_arg = sys.argv[1]
    download_midjourney_job(input_arg)
