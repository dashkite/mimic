import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export storage =
  clear: Generic.make
    name: "Mimic.storage.clear"
    default: ( target ) ->
      throw new Error "storage.clear: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

storage.clear.define [ isPage ], ( page ) ->
  page.evaluate ->
    localStorage.clear()
    sessionStorage.clear()

storage.clear.define [ Array ], ( items ) ->
  Promise.all ( items.map ( item ) -> storage.clear item )
