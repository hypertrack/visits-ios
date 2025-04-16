alias g := generate
alias ogp := open-github-prs
alias us := update-sdk
alias v := version

REPOSITORY_URL := "https://github.com/hypertrack/visits-ios"

# Source: https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# \ are escaped
SEMVER_REGEX := "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"

generate:
  #sourcery --sources Visits --templates Templates/Prism.swifttemplate --output Visits/Logic/App/Sources/App
  sourcery --sources Visits/Modules/Sources/Types --templates Templates/AutoCodable.swifttemplate --output Visits/Modules/Sources/Types --disableCache

open-github-prs:
  open "{{REPOSITORY_URL}}/pull/"

update-sdk app_version version branch="true" commit="true":
  #!/usr/bin/env sh
  set -euo pipefail

  if [ "{{branch}}" = "true" ] ; then
    git checkout -b update-sdk-{{version}}
  fi

  PACKAGE_FILE="Visits/Modules/Package.swift"
  awk '{
    if ($0 ~ /HyperTrack", url: "https:\/\/github.com\/hypertrack\/sdk-ios",[ ]*.exact\("[0-9]+\.[0-9]+\.[0-9]+"\)\),/){
       sub(/[0-9]+\.[0-9]+\.[0-9]+/, "{{version}}");
    }
    print;
  }' $PACKAGE_FILE > tmp && mv tmp $PACKAGE_FILE

  cp Visits.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved Visits/Modules/Package.resolved
  cd Visits/Modules
  swift package resolve
  cd ../..
  cp Visits/Modules/Package.resolved Visits.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
  rm -f Visits/Modules/Package.resolved

  APP_VERSION_FILE="Visits.xcodeproj/project.pbxproj"
  awk '{
    if ($0 ~ /MARKETING_VERSION = [0-9]+\.[0-9]+\.[0-9];/){
       sub(/[0-9]+\.[0-9]+\.[0-9]/, "{{app_version}}");
    }
    print;
  }' $APP_VERSION_FILE > tmp && mv tmp $APP_VERSION_FILE

  if [ "{{commit}}" = "true" ] ; then
    git add .
    git commit -m "Update HyperTrack SDK iOS to {{version}}"
  fi

  if [ "{{branch}}" = "true" ] && [ "{{commit}}" = "true" ] ; then
    just open-github-prs
  fi

version:
  @cat Visits.xcodeproj/project.pbxproj | grep MARKETING_VERSION | head -n 1 | grep -o -E '{{SEMVER_REGEX}}'
