import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export scroll = Generic.make
  name: "Mimic.scroll"
  default: ( target, position ) ->
    throw new Error "scroll: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ position?.constructor?.name ? typeof position } ]."

scroll.define [ isPage, String ], ( page, position ) ->
  if position == "bottom"
    page.evaluate -> window.scrollTo 0, document.body.scrollHeight
