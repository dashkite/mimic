import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export clock =
  tick: Generic.make
    name: "Mimic.clock.tick"
    default: ( target, ms ) ->
      throw new Error "clock.tick: expected Page and Number,
        but received [ #{ target?.constructor?.name ? typeof target } ]
        and [ #{ ms?.constructor?.name ? typeof ms } ]."

clock.tick.define [ isPage, Number ], ( page, ms ) ->
  client = await page.createCDPSession()
  client.send "Emulation.setVirtualTimePolicy",
    policy: "advance"
    budget: ms
