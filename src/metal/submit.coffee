import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export submit = Generic.make
  name: "Mimic.submit"
  default: ( target ) ->
    throw new Error "submit: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

submit.define [ ElementHandle ], ( element ) ->
  element.evaluate ( node ) ->
    if node.requestSubmit
      node.requestSubmit()
    else
      button = node.querySelector 'button[type="submit"], input[type="submit"]'
      if button
        button.click()
      else
        node.submit()

submit.define [ Array ], ( elements ) -> submit elements[0]
