import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"

export attribute = Generic.make
  name: "Mimic.attribute"
  default: ( target ) ->
    throw new Error "attribute: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

attribute.define [ ElementHandle, String ], ( element, name ) ->
  element.evaluate ( ( node, name ) -> node.getAttribute name ), name

attribute.define [ Array, String ], ( elements, name ) ->
  Promise.all ( elements.map ( element ) -> attribute element, name )
