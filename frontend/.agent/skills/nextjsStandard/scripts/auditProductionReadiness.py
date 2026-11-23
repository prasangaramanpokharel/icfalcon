#!/usr/bin/env python3
"""
auditProductionReadiness.py
Automated auditor that scans a Next.js App Router project for production checklist compliance.
"""

import os
import re
import sys

def audit_project(root_dir: str):
    issues = []
    passes = []

    # 1. Check .gitignore for .env
    gitignore_path = os.path.join(root_dir, ".gitignore")
    if os.path.exists(gitignore_path):
        with open(gitignore_path, "r", encoding="utf-8") as f:
            content = f.read()
            if ".env" in content:
                passes.append(".gitignore correctly excludes .env files")
            else:
                issues.append("Security: .gitignore is missing .env exclusion rules")
    else:
        issues.append("Security: Missing root .gitignore")

    # 2. Check next.config for standalone output
    config_found = False
    for conf_name in ["next.config.ts", "next.config.js", "next.config.mjs"]:
        conf_path = os.path.join(root_dir, conf_name)
        if os.path.exists(conf_path):
            config_found = True
            with open(conf_path, "r", encoding="utf-8") as f:
                c = f.read()
                if "output" in c and "standalone" in c:
                    passes.append("Docker: output: 'standalone' detected in next.config")
                else:
                    issues.append("Deployment: next.config is missing output: 'standalone' (recommended for containerization)")
            break

    # 3. Check for global-error.tsx in app
    app_dir = os.path.join(root_dir, "app")
    if not os.path.exists(app_dir):
        app_dir = os.path.join(root_dir, "src", "app")

    if os.path.exists(app_dir):
        files = os.listdir(app_dir)
        if any("global-error" in f for f in files):
            passes.append("Resilience: global-error.tsx found in root app directory")
        else:
            issues.append("Resilience: Missing app/global-error.tsx for root layout error boundaries")

    # 4. Check for database leakage in "use client" files
    forbidden_db_patterns = [r"from ['\"]@prisma", r"from ['\"]drizzle-orm", r"from ['\"]pg['\"]"]
    for current_root, _, current_files in os.walk(root_dir):
        if "node_modules" in current_root or ".next" in current_root:
            continue
        for file in current_files:
            if file.endswith((".tsx", ".jsx", ".ts", ".js")):
                fp = os.path.join(current_root, file)
                try:
                    with open(fp, "r", encoding="utf-8", errors="ignore") as f:
                        text = f.read()
                        if '"use client"' in text or "'use client'" in text:
                            for pat in forbidden_db_patterns:
                                if re.search(pat, text):
                                    issues.append(f"Security Leak: Database import found inside Client Component: {fp}")
                except Exception:
                    pass

    print("=== Next.js Production Readiness Audit ===")
    print(f"\n Passed Checks ({len(passes)}):")
    for p in passes:
        print(f"  • {p}")

    if issues:
        print(f"\n Action Items & Warnings ({len(issues)}):")
        for i in issues:
            print(f"  ▲ {i}")
    else:
        print("\n Excellent: No production checklist violations found!")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "."
    audit_project(target)
