import Generic from "@dashkite/generic"
import { JSHandle } from "puppeteer"
import { isPage } from "./predicates"
export evaluate = Generic.make
  name: "Mimic.evaluate"
  default: ( target ) ->
    throw new Error "evaluate: expected Page or Handle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

evaluate.define [ isPage, Function ], ( page, f ) -> 
  page.evaluate f

evaluate.define [ JSHandle, Function ], ( handle, f ) -> 
  handle.evaluate f

evaluate.define [ Array, Function ], ( items, f ) ->
  Promise.all ( items.map ( item ) -> evaluate item, f )
