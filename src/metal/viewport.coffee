import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export viewport = Generic.make
  name: "Mimic.viewport"
  default: ( target ) ->
    throw new Error "viewport: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

viewport.define [ isPage, Object ], ( page, options ) ->
  page.setViewport options

viewport.define [ Array, Object ], ( items, options ) ->
  Promise.all ( items.map ( item ) -> viewport item, options )
