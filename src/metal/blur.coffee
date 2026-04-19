import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export blur = Generic.make
  name: "Mimic.blur"
  default: ( target ) ->
    throw new Error "blur: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

blur.define [ ElementHandle ], ( element ) ->
  element.evaluate ( node ) -> node.blur()

blur.define [ Array ], ( elements ) -> blur elements[0]
