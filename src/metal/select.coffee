import Generic from "@dashkite/generic"
import { ElementHandle, JSHandle } from "puppeteer"
import { isPage } from "./predicates"

export select = Generic.make
  name: "Mimic.select"
  default: ( target ) -> 
    throw new Error "select: expected Page, ElementHandle, or ShadowRoot handle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have a valid context for querying."

select.define [ isPage, String ], ( page, selector ) -> 
  page.$$ selector

select.define [ ElementHandle, String ], ( element, selector ) -> 
  element.$$ selector

select.define [ JSHandle, String ], ( handle, selector ) ->
  list = await handle.evaluateHandle ( ( node, selector ) -> 
    node.querySelectorAll selector
  ), selector
  properties = await list.getProperties()
  handles = []
  for [ _, prop ] from properties
    if ( element = prop.asElement() )?
      handles.push element
  handles

select.define [ Array, String ], ( targets, selector ) ->
  results = await Promise.all do ->
    targets.map ( target ) -> select target, selector
  results.flat()
