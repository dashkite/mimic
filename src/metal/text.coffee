import Generic from "@dashkite/generic"
export text = Generic.make
  name: "Mimic.text"
  default: ( target ) ->
    throw new Error "text: expected array of ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

text.define [ Array ], ( elements ) ->
  results = []
  for element in elements
    results.push await element.evaluate ( node ) -> node.textContent
  results
