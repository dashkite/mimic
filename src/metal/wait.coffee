import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export wait = Generic.make
  name: "Mimic.wait"
  default: ( target ) ->
    throw new Error "wait: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

wait.define [ isPage, Object ], ( page, options ) ->
  page.waitForNetworkIdle do ->
    Object.assign { idleTime: 500, timeout: 10000 }, options
