import * as Fn from "@dashkite/joy/function"
import * as Time from "@dashkite/joy/time"
import * as K from "@dashkite/katana/async"
import Agents from "./agents"

Mimic =

  start: ( browser ) ->
    Fn.flow [
      Fn.wrap { browser }
      K.read "browser"
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

  select: ( selector ) -> K.push ( node ) -> node.$$ selector
  
  scroll: ( position ) ->
    switch position
      when "bottom"
        K.peek ( page ) -> 
          page.evaluate -> 
            window.scrollTo 0, window.document.body.scrollHeight

  # Node Operations

  text: K.push ( nodes ) ->
    Promise.all nodes.map ( node ) -> 
      node.evaluate ( node ) -> node.textContent

  click: K.peek ([ node ]) -> node?.evaluate ( node ) -> node.click()

  clear: K.peek ([ node ]) -> node?.evaluate ( node ) -> node.value = ""

  type: ( text ) ->
    K.peek ([ node ]) -> node?.type text

export default Mimic

