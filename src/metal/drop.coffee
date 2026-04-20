import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export drop = Generic.make
  name: "Mimic.drop"
  default: ( target ) ->
    throw new Error "drop: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

drop.define [ ElementHandle ], ( element ) ->
  box = await element.boundingBox()
  x = box.x + box.width / 2
  y = box.y + box.height / 2
  await element.frame.page().mouse.move x, y
  element.frame.page().mouse.up()

drop.define [ Array ], ( elements ) ->
  Promise.all ( elements.map ( element ) -> drop element )
