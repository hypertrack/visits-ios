alias a := add
alias i := install
alias l := lint
alias o := open


add framework:
    # Create folders
    mkdir {{framework}}
    mkdir {{framework}}Tests
    # Add Info.plist
    @echo '<?xml version="1.0" encoding="UTF-8"?>' >> ./{{framework}}/Info.plist
    @echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ./{{framework}}/Info.plist
    @echo '<plist version="1.0">' >> ./{{framework}}/Info.plist
    @echo '<dict>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleDevelopmentRegion</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>$(DEVELOPMENT_LANGUAGE)</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleExecutable</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>$(EXECUTABLE_NAME)</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleIdentifier</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleInfoDictionaryVersion</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>6.0</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleName</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>$(PRODUCT_NAME)</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundlePackageType</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleShortVersionString</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>1.0</string>' >> ./{{framework}}/Info.plist
    @echo '    <key>CFBundleVersion</key>' >> ./{{framework}}/Info.plist
    @echo '    <string>$(CURRENT_PROJECT_VERSION)</string>' >> ./{{framework}}/Info.plist
    @echo '</dict>' >> ./{{framework}}/Info.plist
    @echo '</plist>' >> ./{{framework}}/Info.plist
    # Add .h
    @echo '#import <Foundation/Foundation.h>' >> ./{{framework}}/{{framework}}.h
    @echo 'FOUNDATION_EXPORT double {{framework}}VersionNumber;' >> ./{{framework}}/{{framework}}.h
    @echo 'FOUNDATION_EXPORT const unsigned char {{framework}}VersionString[];' >> ./{{framework}}/{{framework}}.h
    # Add .swift
    @echo 'import ComposableArchitecture' >> ./{{framework}}/{{framework}}.swift
    @echo '' >> ./{{framework}}/{{framework}}.swift
    @echo '' >> ./{{framework}}/{{framework}}.swift
    # Add targets to XcodeGen
    @echo '  {{framework}}:' >> project.yml
    @echo '    templates:' >> project.yml
    @echo '      - FrameworkLogic' >> project.yml
    @echo '  {{framework}}Tests:' >> project.yml
    @echo '    templates:' >> project.yml
    @echo '      - Test' >> project.yml
    @echo '    templateAttributes:' >> project.yml
    @echo '      depT: {{framework}}' >> project.yml
    # Add Info.plist to Tests
    @echo '<?xml version="1.0" encoding="UTF-8"?>' >> ./{{framework}}Tests/Info.plist
    @echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ./{{framework}}Tests/Info.plist
    @echo '<plist version="1.0">' >> ./{{framework}}Tests/Info.plist
    @echo '<dict>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleDevelopmentRegion</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>$(DEVELOPMENT_LANGUAGE)</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleExecutable</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>$(EXECUTABLE_NAME)</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleIdentifier</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleInfoDictionaryVersion</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>6.0</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleName</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>$(PRODUCT_NAME)</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundlePackageType</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleShortVersionString</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>1.0</string>' >> ./{{framework}}Tests/Info.plist
    @echo '    <key>CFBundleVersion</key>' >> ./{{framework}}Tests/Info.plist
    @echo '    <string>1</string>' >> ./{{framework}}Tests/Info.plist
    @echo '</dict>' >> ./{{framework}}Tests/Info.plist
    @echo '</plist>' >> ./{{framework}}Tests/Info.plist
    # Add sample test
    @echo 'import XCTest' >> ./{{framework}}Tests/{{framework}}Tests.swift
    @echo '@testable import Reachability' >> ./{{framework}}Tests/{{framework}}Tests.swift
    @echo '' >> ./{{framework}}Tests/{{framework}}Tests.swift
    @echo 'class ReachabilityTests: XCTestCase {' >> ./{{framework}}Tests/{{framework}}Tests.swift
    @echo '  func testExample() { }' >> ./{{framework}}Tests/{{framework}}Tests.swift
    @echo '}' >> ./{{framework}}Tests/{{framework}}Tests.swift


install:
    rm -rf Pods Logistics.xcodeproj Logistics.xcworkspace
    xcodegen generate
    pod install

lint:
    swiftlint lint

open:
    open Logistics.xcworkspace

