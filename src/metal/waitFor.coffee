import Generic from "@dashkite/generic"
import { isTarget } from "./predicates"
export waitFor = Generic.make
  name: "Mimic.waitFor"
  default: ( target ) ->
    throw new Error "waitFor: expected Page or Handle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

waitFor.define [ isTarget, String, Object ], ( target, selector, options ) ->
  options.timeout ?= 10000
  target.waitForSelector selector, options

waitFor.define [ isTarget, Function, Object ],
  ( target, condition, options ) ->
    options.timeout ?= 10000
    target.waitForFunction condition, options
