import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export focus = Generic.make
  name: "Mimic.focus"
  default: ( target ) ->
    throw new Error "focus: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

focus.define [ ElementHandle ], ( element ) ->
  element.focus()

focus.define [ Array ], ( elements ) -> focus elements[0]
