import os
import shutil
from pathlib import Path
from PIL import Image
import concurrent.futures

SRC_ROOT = Path("/home/sticks/Pictures/Redbubble")
DST_ROOT = Path("/tmp/Printify_workspace_3800x4300")
TARGET_W = 3800
TARGET_H = 4300

IMAGE_EXTS = {".png", ".jpg", ".jpeg"}

def process_file(rel_path):
    src_path = SRC_ROOT / rel_path
    dst_path = DST_ROOT / rel_path
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    
    ext = src_path.suffix.lower()
    
    if ext in IMAGE_EXTS:
        try:
            with Image.open(src_path) as im:
                im = im.convert("RGBA")
                src_w, src_h = im.size
                
                # Fit aspect ratio
                scale = min(TARGET_W / src_w, TARGET_H / src_h)
                new_w = int(round(src_w * scale))
                new_h = int(round(src_h * scale))
                
                # Resize
                resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
                
                # Letterbox onto transparent 3800x4300 canvas
                canvas = Image.new("RGBA", (TARGET_W, TARGET_H), (0, 0, 0, 0))
                offset_x = (TARGET_W - new_w) // 2
                offset_y = (TARGET_H - new_h) // 2
                canvas.paste(resized, (offset_x, offset_y))
                
                # Save as PNG
                out_path = dst_path.with_suffix(".png")
                canvas.save(out_path, format="PNG", optimize=False)
                return f"PROCESSED: {rel_path} -> {out_path.name} ({new_w}x{new_h} padded to {TARGET_W}x{TARGET_H})"
        except Exception as e:
            # Fallback copy
            shutil.copy2(src_path, dst_path)
            return f"ERROR on {rel_path}: {e} (copied original)"
    else:
        # Non-image file, copy directly
        shutil.copy2(src_path, dst_path)
        return f"COPIED: {rel_path}"

def main():
    all_files = [p.relative_to(SRC_ROOT) for p in SRC_ROOT.rglob("*") if p.is_file()]
    print(f"Total files to process: {len(all_files)}")
    
    with concurrent.futures.ProcessPoolExecutor() as executor:
        results = list(executor.map(process_file, all_files))
        
    print(f"Finished processing {len(results)} files.")

if __name__ == "__main__":
    main()
