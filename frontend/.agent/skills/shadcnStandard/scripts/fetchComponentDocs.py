#!/usr/bin/env python3
"""
fetchComponentDocs.py
Fetches raw component MDX documentation or CLI docs for any shadcn component.
"""

import sys
import argparse
import urllib.request
import subprocess

GITHUB_BASE_URL = "https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/www/content/docs/components"

def fetch_mdx(component: str, save_path: str = None):
    url = f"{GITHUB_BASE_URL}/{component}.mdx"
    print(f"Fetching MDX from: {url}")
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as response:
            content = response.read().decode("utf-8")
            if save_path:
                with open(save_path, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f" Saved {component}.mdx to {save_path}")
            else:
                print("\n--- Component MDX Content ---")
                print(content[:1500] + ("\n... [truncated]" if len(content) > 1500 else ""))
            return content
    except Exception as e:
        print(f"Direct MDX fetch failed: {e}. Falling back to CLI docs...")
        try:
            res = subprocess.run(["npx", "shadcn@latest", "docs", component], capture_output=True, text=True)
            print(res.stdout or res.stderr)
        except Exception as cli_err:
            print(f"CLI docs also failed: {cli_err}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch shadcn component MDX documentation")
    parser.add_argument("--component", required=True, help="Component name (e.g. button, dialog, sidebar)")
    parser.add_argument("--save", help="Optional output path to save the .mdx file")
    args = parser.parse_args()

    fetch_mdx(args.component, args.save)
