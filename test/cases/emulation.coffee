import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ->
  test "Emulation", [

    test "shorthands (agent, viewport)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.agent "agent/mac/webkit"
        Mimic.viewport "view/hd"
        Mimic.evaluate -> 
          userAgent: navigator.userAgent
          width: window.innerWidth
          height: window.innerHeight
      ]
      [ browser, ..., result ] = stack
      assert result.userAgent.includes "Safari"
      assert.equal result.width, 1920
      assert.equal result.height, 1080
      await browser.close()

    test "media", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <style>
            @media print { body { color: rgb(255, 0, 0); } }
          </style>
          <body>Media Test</body>
        """
        Mimic.media "print"
        Mimic.evaluate -> getComputedStyle(document.body).color
        K.peek ( color ) -> assert.equal color, "rgb(255, 0, 0)"
      ]
      [ browser ] = stack
      await browser.close()

  ]
