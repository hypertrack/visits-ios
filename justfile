alias i := install
alias l := lint
alias o := open


install:
    rm -rf Pods Logistics.xcworkspace
    pod install

lint:
    swiftlint lint

open:
    open Logistics.xcworkspace

