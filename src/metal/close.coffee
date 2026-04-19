import Generic from "@dashkite/generic"

isClosable = ( x ) -> x?.close?

export close = Generic.make
  name: "Mimic.close"
  default: ( target ) ->
    throw new Error "close: expected a closable target,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

close.define [ isClosable ], ( target ) -> target.close()
