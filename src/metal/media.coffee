import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export media = Generic.make
  name: "Mimic.media"
  default: ( target, type ) ->
    throw new Error "media: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ type?.constructor?.name ? typeof type } ]."

media.define [ isPage, String ], ( page, type ) ->
  page.emulateMediaType type

media.define [ isPage, String, Object ], ( page, type, features ) ->
  page.emulateMediaType type
  page.emulateMediaFeatures features

media.define [ Array, String ], ( items, type ) ->
  Promise.all ( items.map ( item ) -> media item, type )

media.define [ Array, String, Object ], ( items, type, features ) ->
  Promise.all ( items.map ( item ) -> media item, type, features )
