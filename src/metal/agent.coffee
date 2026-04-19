import Generic from "@dashkite/generic"
import { isPage } from "./predicates"
export agent = Generic.make
  name: "Mimic.agent"
  default: ( target, agent ) ->
    throw new Error "agent: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ agent?.constructor?.name ? typeof agent } ]."

agent.define [ isPage, String ], ( page, agent ) ->
  page.setUserAgent agent
