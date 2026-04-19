import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export hover = Generic.make
  name: "Mimic.hover"
  default: ( target ) ->
    throw new Error "hover: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

hover.define [ ElementHandle ], ( element ) ->
  element.hover()

hover.define [ Array ], ( elements ) -> hover elements[0]
