alias g := generate
alias us := update-sdk

generate:
  #sourcery --sources Visits --templates Templates/Prism.swifttemplate --output Visits/Logic/App/Sources/App
  sourcery --sources Visits/Modules/Sources/Types --templates Templates/AutoCodable.swifttemplate --output Visits/Modules/Sources/Types --disableCache

update-sdk version:
  #!/usr/bin/env sh
  set -euo pipefail

  PACKAGE_FILE="Visits/Modules/Package.swift"

  awk '{
    if ($0 == "    .package(name: \"HyperTrack\", url: \"https://github.com/hypertrack/sdk-ios\",                                .exact(\"5.5.4\"))," )
        print "    .package(name: \"HyperTrack\", url: \"https://github.com/hypertrack/sdk-ios\",                                .exact(\"{{version}}\")),";
    else
        print;
  }' $PACKAGE_FILE > tmp && mv tmp $PACKAGE_FILE

  echo "Package version updated successfully."

  cp Visits.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved Visits/Modules/Package.resolved
  cd Visits/Modules
  swift package resolve
  cd ../..
  cp Visits/Modules/Package.resolved Visits.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
  rm -f Visits/Modules/Package.resolved

