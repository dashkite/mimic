import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export forward = Generic.make
  name: "Mimic.forward"
  default: ( target ) ->
    throw new Error "forward: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

forward.define [ isPage ], ( page ) ->
  page.goForward waitUntil: "networkidle2"
