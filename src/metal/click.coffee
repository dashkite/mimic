import Generic from "@dashkite/generic"
export click = Generic.make
  name: "Mimic.click"
  default: ( target ) ->
    throw new Error "click: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

click.define [ require("puppeteer").ElementHandle ], ( element ) -> 
  element.click()

click.define [ Array ], ( elements ) ->
  Promise.all ( elements.map ( element ) -> click element )
