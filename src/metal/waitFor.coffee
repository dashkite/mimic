import Generic from "@dashkite/generic"
import { isTarget } from "./predicates"
export waitFor = Generic.make
  name: "Mimic.waitFor"
  default: ( target ) ->
    throw new Error "waitFor: expected Page or Handle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

waitFor.define [ isTarget, String, Object ], ( target, selector, options ) ->
  options.timeout ?= 1000
  target.waitForSelector selector, options

waitFor.define [ isTarget, Function, Object ],
  ( target, condition, options ) ->
    options.timeout ?= 1000
    target.waitForFunction condition, options

waitFor.define [ Array, String, Object ], ( items, selector, options ) ->
  Promise.all ( items.map ( item ) -> waitFor item, selector, options )

waitFor.define [ Array, Function, Object ], ( items, condition, options ) ->
  Promise.all ( items.map ( item ) -> waitFor item, condition, options )
