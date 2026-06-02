"""OCR every rendered page of the book with EasyOCR (Arabic) and emit a
search index: {"pages": [{"p": <1-based pdf page>, "lines": [...]}, ...]}.

Run with the venv:  ./venv/bin/python run_ocr.py
"""
import glob
import json
import os
import sys

import easyocr

PAGES_DIR = "pages"
OUT = "search_index_raw.json"


def main():
    reader = easyocr.Reader(["ar"], gpu=False, verbose=False)
    pages = sorted(glob.glob(os.path.join(PAGES_DIR, "page-*.png")))
    if not pages:
        print("no page images found", file=sys.stderr)
        sys.exit(1)

    result_pages = []
    for i, path in enumerate(pages, start=1):
        try:
            # paragraph=True groups detected words into readable blocks.
            blocks = reader.readtext(path, detail=0, paragraph=True)
            lines = [b.strip() for b in blocks if b and b.strip()]
        except Exception as e:  # noqa: BLE001
            print(f"page {i}: ERROR {e}", file=sys.stderr)
            lines = []
        result_pages.append({"p": i, "lines": lines})
        print(f"page {i}/{len(pages)}: {len(lines)} blocks", flush=True)

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump({"pages": result_pages}, f, ensure_ascii=False)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
