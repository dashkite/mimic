import Generic from "@dashkite/generic"
import { ElementHandle } from "puppeteer"
import { isPage } from "./predicates"
export screenshot =
  image: Generic.make
    name: "Mimic.screenshot.image"
    default: ( target ) ->
      throw new Error "screenshot.image: expected Page or ElementHandle,
        but received [ #{ target?.constructor?.name ? typeof target } ]."
  pdf: Generic.make
    name: "Mimic.screenshot.pdf"
    default: ( target ) ->
      throw new Error "screenshot.pdf: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

screenshot.image.define [ isPage, Object ], ( page, options ) ->
  page.screenshot options

screenshot.image.define [ ElementHandle, Object ], ( element, options ) ->
  element.screenshot options

screenshot.pdf.define [ isPage, Object ], ( page, options ) ->
  page.pdf options
