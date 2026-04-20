import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"

export text = Generic.make
  name: "Mimic.text"
  default: ( target ) ->
    throw new Error "text: expected ElementHandle or array,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

text.define [ Array ], ( elements ) ->
  results = []
  for element in elements
    results.push await element.evaluate ( node ) -> node.textContent
  results

text.define [ ElementHandle ], ( element ) -> text [ element ]
