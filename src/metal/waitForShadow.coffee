import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"

export waitForShadow = Generic.make
  name: "Mimic.waitForShadow"
  default: ( target ) ->
    throw new Error "waitForShadow: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

waitForShadow.define [ ElementHandle ], ( element ) ->
  page = element.frame.page()
  await page.waitForFunction ( ( node ) -> node.shadowRoot? ), {}, element
  element

waitForShadow.define [ Array ], ( elements ) ->
  Promise.all ( elements.map ( element ) -> waitForShadow element )
