import Generic from "@dashkite/generic"
import { BrowserContext } from "puppeteer"
import { isPage } from "./predicates"
export cookies =
  get: Generic.make
    name: "Mimic.cookies.get"
    default: ( target ) ->
      throw new Error "cookies.get: expected Page or BrowserContext,
        but received [ #{ target?.constructor?.name ? typeof target } ]."
  set: Generic.make
    name: "Mimic.cookies.set"
    default: ( target ) ->
      throw new Error "cookies.set: expected Page or BrowserContext,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

cookies.get.define [ isPage ], ( page ) -> page.cookies()
cookies.get.define [ BrowserContext ], ( context ) -> context.cookies()

cookies.set.define [ isPage, Array ], ( page, cookies ) -> 
  page.setCookie ...cookies

cookies.set.define [ BrowserContext, Array ], ( context, cookies ) ->
  context.setCookie ...cookies
