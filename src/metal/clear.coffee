import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export clear = Generic.make
  name: "Mimic.clear"
  default: ( target ) ->
    throw new Error "clear: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

clear.define [ ElementHandle ], ( element ) ->
  element.evaluate ( node ) -> node.value = ""

clear.define [ Array ], ( elements ) ->
  Promise.all ( elements.map ( element ) -> clear element )
