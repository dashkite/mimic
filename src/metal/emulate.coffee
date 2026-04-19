import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export emulate = Generic.make
  name: "Mimic.emulate"
  default: ( target, device ) ->
    throw new Error "emulate: expected Page and either String or Object,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ device?.constructor?.name ? typeof device } ]."

emulate.define [ isPage, String ], ( page, userAgent ) ->
  page.setUserAgent userAgent

emulate.define [ isPage, Object ], ( page, device ) ->
  page.emulate device
