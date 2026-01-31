.PHONY: generate open clean build test l10n icon

# Generate localization files from JSON source
l10n:
	python3 scripts/generate_locales.py

# Generate app icon from SF Symbol
icon:
	swift scripts/generate_appicon.swift

generate: l10n
	xcodegen generate

open: generate
	open CleanLock.xcodeproj

clean:
	rm -rf CleanLock.xcodeproj
	rm -rf build

build: generate
	xcodebuild -project CleanLock.xcodeproj -scheme CleanLock -configuration Debug build

test: generate
	xcodebuild -project CleanLock.xcodeproj -scheme CleanLockTests -configuration Debug test
