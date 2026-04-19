import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ( start ) ->

  preamble = pipe [
    start
    Mimic.context
    Mimic.page
  ]

  test "Emulation", [

    test "shorthands (agent, viewport)", pipe [
      preamble
      Mimic.agent "agent/mac/webkit"
      Mimic.viewport "view/hd"
      Mimic.evaluate -> 
        userAgent: navigator.userAgent
        width: window.innerWidth
        height: window.innerHeight
      K.peek ( result ) ->
        assert result.userAgent.includes "Safari"
        assert.equal result.width, 1920
        assert.equal result.height, 1080
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "media", pipe [
      preamble
      Mimic.goto """data:text/html,
        <style>
          @media print { body { color: rgb(255, 0, 0); } }
        </style>
        <body>Media Test</body>
      """
      Mimic.media "print"
      Mimic.evaluate -> getComputedStyle(document.body).color
      K.peek ( color ) -> assert.equal color, "rgb(255, 0, 0)"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

  ]
