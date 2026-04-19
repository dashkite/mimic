import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export media = Generic.make
  name: "Mimic.media"
  default: ( target ) ->
    throw new Error "media: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

media.define [ isPage, String ], ( page, type ) ->
  page.emulateMediaType type

media.define [ isPage, String, Array ], ( page, type, features ) ->
  await page.emulateMediaType type
  page.emulateMediaFeatures features
