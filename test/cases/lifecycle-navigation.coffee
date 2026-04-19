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

  test "Lifecycle & Navigation", [

    test "browser, context, page", pipe [
      preamble
      ( stack ) ->
        [ browser, context, page ] = stack
        assert browser?
        assert context?
        assert page?
        context.close()
    ]

    test "goto, select, text", pipe [
      preamble
      Mimic.goto "data:text/html,<h1>Mimic Test</h1>"
      Mimic.select "h1"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Mimic Test"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "reload, back, forward", pipe [
      preamble
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
        context.close()
    ]

  ]
