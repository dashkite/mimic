import Generic from "@dashkite/generic"
export attribute = Generic.make
  name: "Mimic.attribute"
  default: ( target ) ->
    throw new Error "attribute: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

attribute.define [ require("puppeteer").ElementHandle, String ], ( element, name ) ->
  element.evaluate ( ( node, name ) -> node.getAttribute name ), name

attribute.define [ Array, String ], ( elements, name ) ->
  attribute elements[0], name
