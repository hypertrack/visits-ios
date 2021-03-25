alias g := generate

generate:
  #sourcery --sources Visits --templates Templates/Prism.swifttemplate --output Visits/Logic/App/Sources/App
  sourcery --sources Visits/Modules/Sources/Types --templates Templates/AutoCodable.swifttemplate --output Visits/Modules/Sources/Types 
