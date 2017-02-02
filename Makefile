lint:
	@echo "--> Running swiftlint"
	swiftlint

test:
	@echo "--> Running all tests"
	fastlane test

build-carthage:
	@echo "--> Creating Sentry framework package with carthage"
	carthage build --no-skip-current
	carthage archive Sentry

release: lint test pod-example-projects pod-lint build-carthage

build-time:
	@echo "--> Analysing build time"
	xcodebuild -verbose -project Sentry.xcodeproj -scheme Sentry-iOS -sdk iphonesimulator clean build OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-function-bodies" | grep ".[0-9]ms" | grep -v "^0.[0-9]ms" | sort -nr > culprits.txt
	open culprits.txt

pod-lint:
	@echo "--> Build local pod"
	pod lib lint --allow-warnings

pod-example-projects:
	@echo "--> Running pod install on all example projects"
	pod repo update
	pod update --project-directory=Examples/SwiftExample
	pod update --project-directory=Examples/SwiftTVOSExample
	pod update --project-directory=Examples/SwiftWatchOSExample
	pod update --project-directory=Examples/ObjcExample
	pod update --project-directory=Examples/MacExample

pod-release:
	@echo "--> Releasing Pod"
	pod trunk push Sentry.podspec --allow-warnings
