import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export press = Generic.make
  name: "Mimic.press"
  default: ( target, key ) ->
    throw new Error "press: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ key?.constructor?.name ? typeof key } ]."

press.define [ isPage, String ], ( page, key ) ->
  page.keyboard.press key
