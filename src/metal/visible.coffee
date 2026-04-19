import Generic from "@dashkite/generic"
export visible = Generic.make
  name: "Mimic.visible"
  default: ( target ) ->
    throw new Error "visible: expected array of ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

visible.define [ Array ], ( elements ) ->
  results = []
  for element in elements
    if await element.isVisible()
      results.push element
  results
