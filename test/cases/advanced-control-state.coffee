import FS from "fs"
import Path from "path"
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
    Mimic.goto "https://httpbin.org/html"
  ]

  test "Advanced Control & State", [

    test "storage", pipe [
      preamble
      Mimic.evaluate -> localStorage.setItem "test-key", "test-value"
      K.drop
      Mimic.storage.clear
      Mimic.evaluate -> localStorage.getItem "test-key"
      K.peek ( value ) -> assert value == null
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "cookies", pipe [
      preamble
      Mimic.goto "https://httpbin.org/cookies/set?test-cookie=test-value"
      Mimic.cookies.get
      K.peek ( cookies ) ->
        cookie = cookies.find ( c ) -> c.name == "test-cookie"
        assert.equal cookie.value, "test-value"
      K.drop
      Mimic.cookies.set [ name: "another-cookie", value: "another-value", domain: "httpbin.org" ]
      Mimic.cookies.get
      K.peek ( cookies ) ->
        cookie = cookies.find ( c ) -> c.name == "another-cookie"
        assert.equal cookie.value, "another-value"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "mock", pipe [
      preamble
      Mimic.goto "https://httpbin.org/html"
      Mimic.mock /mocked\.json$/, ( request ) ->
        request.respond
          contentType: "application/json"
          body: JSON.stringify greeting: "Hello from Mock"
      Mimic.evaluate ->
        response = await fetch 'mocked.json'
        data = await response.json()
        document.body.textContent = data.greeting
      K.drop
      Mimic.waitFor -> document.body.textContent.includes "Hello from Mock"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "clock", pipe [
      start
      Mimic.context
      Mimic.page
      Mimic.goto """data:text/html,
        <div id="out">Initial</div>
        <script>
          setTimeout(() => {
            document.getElementById('out').textContent = 'Timed Out';
          }, 5000);
        </script>
      """
      Mimic.clock.tick 5000
      Mimic.waitFor -> document.getElementById('out').textContent == 'Timed Out'
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "dialog.accept", pipe [
      start
      Mimic.context
      Mimic.page
      Mimic.dialog.accept
      Mimic.evaluate -> confirm "Are you sure?"
      K.peek ( result ) -> assert result == true
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "dialog.dismiss", pipe [
      start
      Mimic.context
      Mimic.page
      Mimic.dialog.dismiss
      Mimic.evaluate -> confirm "Are you sure?"
      K.peek ( result ) -> assert result == false
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "screenshots", pipe [
      start
      Mimic.context
      Mimic.page
      Mimic.goto "data:text/html,<h1>Screenshot Test</h1>"
      do ->
        tmp = Path.join process.cwd(), "test/tmp/screenshots"
        FS.mkdirSync tmp, recursive: true
        image = Path.join tmp, "test-screenshot.png"
        pdf = Path.join tmp, "test-screenshot.pdf"
        pipe [
          Mimic.screenshot.image path: image
          Mimic.screenshot.pdf path: pdf
          ( stack ) ->
            assert FS.existsSync image
            assert (FS.statSync image).size > 0
            assert FS.existsSync pdf
            assert (FS.statSync pdf).size > 0
            FS.unlinkSync image
            FS.unlinkSync pdf
            FS.rmdirSync tmp
            stack
        ]
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

  ]
