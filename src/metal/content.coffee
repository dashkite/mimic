import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export content = Generic.make
  name: "Mimic.content"
  default: ( target ) ->
    throw new Error "content: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

content.define [ isPage ], ( page ) ->
  page.content()

content.define [ Array ], ( items ) ->
  Promise.all ( items.map ( item ) -> content item )
