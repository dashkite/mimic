import { get } from "@dashkite/joy/object"
import * as Fn from "@dashkite/joy/function"
import * as Time from "@dashkite/joy/time"
import * as K from "@dashkite/katana"
import Agents from "./agents"

Mimic =

  start: ( browser ) ->
    Fn.flow [
      Fn.wrap { browser }
      K.push get "browser"
    ]

  context: K.push ( browser ) -> browser.createBrowserContext()

  page: K.push ( context ) -> context.newPage()

  agent: ( agent ) ->
    K.peek ( page ) -> page.setUserAgent Agents[agent]

  goto: ( url ) -> K.peek ( page ) -> page.goto url

  content: K.push ( page ) -> page.content()

  screenshot: ( path ) ->
    K.peek ( page ) ->
      page.screenshot
        path: path
        captureBeyondViewport: false

  pause: K.peek -> Time.sleep 100

  sleep: ( ms ) -> K.peek -> Time.sleep ms

  wait: K.peek ( page ) ->
    page.waitForNetworkIdle
      idleTime: 500
      timeout: 60000

  waitFor: ( condition, options ) ->
    K.peek ( page ) ->
      if typeof condition == "string"
        page.waitForSelector condition, options
      else
        page.waitForFunction condition, options

  select: ( selector ) -> K.push ( node ) -> node.$$ selector

  evaluate: ( f ) -> K.push ( node ) -> node.evaluate f
  
  scroll: ( position ) ->
    switch position
      when "bottom"
        K.peek ( page ) -> 
          page.evaluate -> 
            window.scrollTo 0, window.document.body.scrollHeight

  # Node Operations

  count: K.push ( nodes ) -> nodes.length

  text: K.push ( nodes ) ->
    Promise.all nodes.map ( node ) -> 
      node.evaluate ( node ) -> node.textContent

  attribute: ( name ) ->
    K.push ([ node ]) ->
      node?.evaluate ( ( node, name ) -> node.getAttribute name ), name

  shadow: K.push ([ node ]) ->
    node?.evaluateHandle ( node ) -> node.shadowRoot

  click: K.peek ([ node ]) -> node?.evaluate ( node ) -> node.click()

  hover: K.peek ([ node ]) -> node?.hover()

  focus: K.peek ([ node ]) -> node?.focus()

  clear: K.peek ([ node ]) -> node?.evaluate ( node ) -> node.value = ""

  type: ( text ) ->
    K.peek ([ node ]) -> node?.type text

  press: ( key ) ->
    K.peek ( page ) -> page.keyboard.press key

  submit: K.peek ([ node ]) ->
    node?.evaluate ( node ) ->
      ( node.requestSubmit?() ) || 
        node.querySelector("button[type='submit'], input[type='submit']")?.click() ||
        node.submit()

export default Mimic
