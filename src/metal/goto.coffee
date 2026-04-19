import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export goto = Generic.make
  name: "Mimic.goto"
  default: ( target, url, options ) ->
    throw new Error "goto: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ url?.constructor?.name ? typeof url } ]."

goto.define [ isPage, String, Object ], ( page, url, options ) ->
  page.goto url, options
