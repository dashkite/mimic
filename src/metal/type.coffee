import Generic from "@dashkite/generic"
export type = Generic.make
  name: "Mimic.type"
  default: ( target ) ->
    throw new Error "type: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have selected the specific input element 
      you wish to type into."

type.define [ require("puppeteer").ElementHandle, String ], ( element, text ) ->
  await element.focus()
  await element.evaluate ( node ) -> node.value = ""
  element.type text

type.define [ Array, String ], ( elements, text ) -> type elements[0], text
