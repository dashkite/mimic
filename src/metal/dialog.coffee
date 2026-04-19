import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export dialog =
  accept: Generic.make
    name: "Mimic.dialog.accept"
    default: ( target ) ->
      throw new Error "dialog.accept: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."
  dismiss: Generic.make
    name: "Mimic.dialog.dismiss"
    default: ( target ) ->
      throw new Error "dialog.dismiss: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

dialog.accept.define [ isPage ], ( page ) ->
  page.on "dialog", ( dialog ) -> dialog.accept()

dialog.dismiss.define [ isPage ], ( page ) ->
  page.on "dialog", ( dialog ) -> dialog.dismiss()
