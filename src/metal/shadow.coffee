import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"

export shadow = Generic.make
  name: "Mimic.shadow"
  default: ( target ) ->
    throw new Error "shadow: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

shadow.define [ ElementHandle ], ( element ) ->
  root = await element.evaluateHandle ( node ) -> node.shadowRoot
  isNull = await root.evaluate ( node ) -> node == null
  if isNull
    throw new Error "shadow: element has no shadowRoot.
      Ensure the component has initialized and attached its shadow DOM."
  root

shadow.define [ Array ], ( elements ) ->
  Promise.all ( elements.map ( element ) -> shadow element )
