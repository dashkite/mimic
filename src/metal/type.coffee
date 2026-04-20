import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"

export type = Generic.make
  name: "Mimic.type"
  default: ( target ) ->
    throw new Error "type: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

type.define [ ElementHandle, String ], ( element, text ) ->
  await element.focus()
  await element.evaluate ( node ) -> node.value = ""
  element.type text

type.define [ Array, String ], ( elements, text ) ->
  Promise.all ( elements.map ( element ) -> type element, text )
