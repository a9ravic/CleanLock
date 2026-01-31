.PHONY: generate open clean build test

generate:
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
