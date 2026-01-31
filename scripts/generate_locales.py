#!/usr/bin/env python3
"""
Generate Xcode String Catalog from JSON source file.

Usage:
    python3 scripts/generate_locales.py

This script reads locales/strings.json and generates:
    - CleanLock/Resources/Localizable.xcstrings
    - CleanLock/Resources/InfoPlist.xcstrings
"""

import json
import os
import sys
from pathlib import Path


def load_strings(json_path: Path) -> dict:
    """Load strings from JSON source file."""
    with open(json_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def validate_strings(data: dict) -> list[str]:
    """Validate that all strings have translations for all languages."""
    warnings = []
    meta = data.get('_meta', {})
    languages = meta.get('languages', [])

    for key, translations in data.items():
        if key.startswith('_'):
            continue

        for lang in languages:
            if lang not in translations:
                warnings.append(f"Missing '{lang}' translation for key '{key}'")

    return warnings


def generate_xcstrings(data: dict, output_path: Path) -> None:
    """Generate Xcode String Catalog (.xcstrings) file."""
    meta = data.get('_meta', {})
    source_language = meta.get('sourceLanguage', 'en')
    languages = meta.get('languages', ['en'])

    # Build xcstrings structure
    xcstrings = {
        "sourceLanguage": source_language,
        "version": "1.0",
        "strings": {}
    }

    for key, translations in data.items():
        if key.startswith('_'):
            continue

        string_entry = {
            "extractionState": "manual",
            "localizations": {}
        }

        for lang in languages:
            if lang in translations:
                string_entry["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translations[lang]
                    }
                }

        xcstrings["strings"][key] = string_entry

    # Write output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(xcstrings, f, ensure_ascii=False, indent=2)

    print(f"Generated: {output_path}")


def generate_infoplist_xcstrings(output_path: Path, source_language: str, languages: list[str]) -> None:
    """Generate InfoPlist.xcstrings for app name localization."""
    # Copyright translations
    copyright_translations = {
        "en": "Copyright © 2024 CleanLock. All rights reserved.",
        "zh-Hans": "版权所有 © 2024 CleanLock。保留所有权利。",
        "es": "Copyright © 2024 CleanLock. Todos los derechos reservados.",
        "hi": "कॉपीराइट © 2024 CleanLock। सर्वाधिकार सुरक्षित।",
        "ar": "حقوق الطبع والنشر © 2024 CleanLock. جميع الحقوق محفوظة.",
        "fr": "Copyright © 2024 CleanLock. Tous droits réservés.",
        "pt-BR": "Copyright © 2024 CleanLock. Todos os direitos reservados."
    }

    # Build localizations for each string
    def build_localizations(value_func):
        localizations = {}
        for lang in languages:
            localizations[lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": value_func(lang)
                }
            }
        return localizations

    xcstrings = {
        "sourceLanguage": source_language,
        "version": "1.0",
        "strings": {
            "CFBundleDisplayName": {
                "extractionState": "manual",
                "localizations": build_localizations(lambda lang: "CleanLock")
            },
            "CFBundleName": {
                "extractionState": "manual",
                "localizations": build_localizations(lambda lang: "CleanLock")
            },
            "NSHumanReadableCopyright": {
                "extractionState": "manual",
                "localizations": build_localizations(
                    lambda lang: copyright_translations.get(lang, copyright_translations["en"])
                )
            }
        }
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(xcstrings, f, ensure_ascii=False, indent=2)

    print(f"Generated: {output_path}")


def main():
    # Determine paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    json_path = project_root / 'locales' / 'strings.json'
    localizable_path = project_root / 'CleanLock' / 'Resources' / 'Localizable.xcstrings'
    infoplist_path = project_root / 'CleanLock' / 'Resources' / 'InfoPlist.xcstrings'

    # Check source file exists
    if not json_path.exists():
        print(f"Error: Source file not found: {json_path}", file=sys.stderr)
        sys.exit(1)

    # Load and validate
    print(f"Loading: {json_path}")
    data = load_strings(json_path)

    warnings = validate_strings(data)
    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"  - {warning}")
        print()

    # Generate files
    meta = data.get('_meta', {})
    source_language = meta.get('sourceLanguage', 'en')
    languages = meta.get('languages', ['en'])

    generate_xcstrings(data, localizable_path)
    generate_infoplist_xcstrings(infoplist_path, source_language, languages)

    # Summary
    string_count = len([k for k in data.keys() if not k.startswith('_')])
    lang_count = len(meta.get('languages', []))
    print(f"\nSummary: {string_count} strings, {lang_count} languages")

    if warnings:
        print(f"Warnings: {len(warnings)}")
        sys.exit(1)
    else:
        print("All translations complete!")


if __name__ == '__main__':
    main()
