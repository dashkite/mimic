import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export accessibility = Generic.make
  name: "Mimic.accessibility"
  default: ( target ) ->
    throw new Error "accessibility: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

accessibility.define [ isPage ], ( page ) ->
  page.accessibility.snapshot()
