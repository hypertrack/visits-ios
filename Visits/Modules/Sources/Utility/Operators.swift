// Get
infix operator *^: infixl8

// Set, Embed
infix operator *<: infixr6

// Modify
infix operator *~: infixr6

// Lift WritableKeyPath to Lens
prefix operator ^

// Lift enum case function to Prism
prefix operator /

// Extract
infix operator *^?: infixl8

// Inject
infix operator *<?: infixr6

// Attempt to Modify
infix operator *~? : infixr6

// Modify or Unchanged
infix operator *~- : infixr6

// Embed or Unchanged
infix operator *<- : infixr6

// Compose Optics
infix operator ** : infixr9


// Application
infix operator |> : infixl1
infix operator <| : infixr0

// Semigroupoid
infix operator >>> : infixr9
infix operator <<< : infixr9

// Semigroup
infix operator <> : infixr5
prefix operator <>
postfix operator <>

// Functor
infix operator <!> : infixl4
infix operator <¡> : infixl1
infix operator <! : infixl4
infix operator !> : infixl4
infix operator >!< : infixl4

// Apply
infix operator <*> : infixl4
infix operator <* : infixl4
infix operator *> : infixl4

// Alt
infix operator <|> : infixl3

// Bind
infix operator >>- : infixl1
infix operator -<< : infixr1

// Kleisli
infix operator >-> : infixr1
infix operator <-< : infixr1

// Selective
infix operator <*? : infixl4
infix operator ?*> : infixl4
infix operator <||> : infixl4
infix operator <&&> : infixl4
