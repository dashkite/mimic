import Generic from "@dashkite/generic"
export shadow = Generic.make
  name: "Mimic.shadow"
  default: ( target ) ->
    throw new Error "shadow: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have selected an element and refined the context 
      with 'first' if necessary."

shadow.define [ require("puppeteer").ElementHandle ], ( element ) ->
  root = await element.evaluateHandle ( node ) -> node.shadowRoot
  isNull = await root.evaluate ( node ) -> node == null
  if isNull
    throw new Error "shadow: element has no shadowRoot.
      Ensure the component has initialized and attached its shadow DOM."
  root

shadow.define [ Array ], ( elements ) -> shadow elements[0]
