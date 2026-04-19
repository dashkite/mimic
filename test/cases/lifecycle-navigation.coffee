import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ->
  test "Lifecycle & Navigation", [

    test "browser, context, page", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.context
        Mimic.page
      ]
      [ browser, context, page ] = stack
      assert browser?
      assert context?
      assert page?
      await browser.close()

    test "goto, select, text", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "data:text/html,<h1>Mimic Test</h1>"
        Mimic.select "h1"
        Mimic.text
      ]
      [ browser, ..., texts ] = stack
      assert.equal texts[0], "Mimic Test"
      await browser.close()

    test "reload, back, forward", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "https://httpbin.org/html"
        Mimic.goto "https://httpbin.org/forms/post"
        Mimic.back
        K.peek ( page ) -> assert page.url().includes "html"
        Mimic.forward
        K.peek ( page ) -> assert page.url().includes "post"
        Mimic.reload
        K.peek ( page ) -> assert page.url().includes "post"
      ]
      [ browser ] = stack
      await browser.close()

  ]
