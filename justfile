alias g := generate

generate:
  #sourcery --sources Visits --templates Templates/Prism.swifttemplate --output Visits/Logic/App/Sources/App
  sourcery --sources Visits/Modules/Sources/Visit --templates Templates/AutoCodable.swifttemplate --output Visits/Modules/Sources/Visit 
