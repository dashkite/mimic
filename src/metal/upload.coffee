import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
export upload = Generic.make
  name: "Mimic.upload"
  default: ( target ) ->
    throw new Error "upload: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

upload.define [ ElementHandle, Array ], ( element, paths ) ->
  element.uploadFile ...paths

upload.define [ Array, Array ], ( elements, paths ) ->
  Promise.all ( elements.map ( element ) -> upload element, paths )
