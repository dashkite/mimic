import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export reload = Generic.make
  name: "Mimic.reload"
  default: ( target ) ->
    throw new Error "reload: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

reload.define [ isPage ], ( page ) ->
  page.reload waitUntil: "networkidle2"
