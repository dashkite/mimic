import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export mock = Generic.make
  name: "Mimic.mock"
  default: ( target, pattern, handler ) ->
    throw new Error "mock: expected Page, RegExp, and Function,
      but received [ #{ target?.constructor?.name ? typeof target } ],
      [ #{ pattern?.constructor?.name ? typeof pattern } ],
      and [ #{ handler?.constructor?.name ? typeof handler } ]."

mock.define [ isPage, RegExp, Function ], ( page, pattern, handler ) ->
  page.on "request", ( request ) ->
    if ( request.url().match pattern )
      handler request
    else
      request.continue()
  await page.setRequestInterception true
