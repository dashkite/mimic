import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export back = Generic.make
  name: "Mimic.back"
  default: ( target ) ->
    throw new Error "back: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

back.define [ isPage ], ( page ) ->
  page.goBack waitUntil: "networkidle2"
