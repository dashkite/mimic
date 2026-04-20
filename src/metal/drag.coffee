import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export drag = Generic.make
  name: "Mimic.drag"
  default: ( target ) ->
    throw new Error "drag: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

drag.define [ ElementHandle ], ( element ) ->
  box = await element.boundingBox()
  x = box.x + box.width / 2
  y = box.y + box.height / 2
  await element.frame.page().mouse.move x, y
  element.frame.page().mouse.down()

drag.define [ Array ], ( elements ) ->
  Promise.all ( elements.map ( element ) -> drag element )
