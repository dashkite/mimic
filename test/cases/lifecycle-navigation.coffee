import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ( start ) ->
  test "Lifecycle & Navigation", [

    test "browser, context, page", ->
      await do pipe [
        start
        Mimic.context
        Mimic.page
        ( stack ) ->
          [ browser, context, page ] = stack
          assert browser?
          assert context?
          assert page?
          await context.close()
      ]

    test "goto, select, text", ->
      await do pipe [
        start
        Mimic.context
        Mimic.page
        Mimic.goto "data:text/html,<h1>Mimic Test</h1>"
        Mimic.select "h1"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Mimic Test"
        ( stack ) ->
          [ browser, context ] = stack
          await context.close()
      ]

    test "reload, back, forward", ->
      await do pipe [
        start
        Mimic.context
        Mimic.page
        Mimic.goto "https://httpbin.org/html"
        Mimic.goto "https://httpbin.org/forms/post"
        Mimic.back
        K.peek ( page ) -> assert page.url().includes "html"
        Mimic.forward
        K.peek ( page ) -> assert page.url().includes "post"
        Mimic.reload
        K.peek ( page ) -> assert page.url().includes "post"
        ( stack ) ->
          [ browser, context ] = stack
          await context.close()
      ]

  ]
