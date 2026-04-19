import FS from "fs"
import Path from "path"
import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ->
  test "Advanced Control & State", [

    test "storage", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "https://httpbin.org/html"
        Mimic.evaluate -> localStorage.setItem "test-key", "test-value"
        K.drop
        Mimic.storage.clear
        Mimic.evaluate -> localStorage.getItem "test-key"
      ]
      [ browser, ..., value ] = stack
      assert value == null
      await browser.close()

    test "cookies", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
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
      ]
      [ browser ] = stack
      await browser.close()

    test "mock", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
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
      ]
      [ browser ] = stack
      await browser.close()

    test "clock", ->
      stack = await do pipe [
        Mimic.browser()
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
      ]
      [ browser ] = stack
      await browser.close()

    test "dialog.accept", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.dialog.accept
        Mimic.evaluate -> confirm "Are you sure?"
        K.peek ( result ) -> assert result == true
      ]
      [ browser ] = stack
      await browser.close()

    test "dialog.dismiss", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.dialog.dismiss
        Mimic.evaluate -> confirm "Are you sure?"
        K.peek ( result ) -> assert result == false
      ]
      [ browser ] = stack
      await browser.close()

    test "screenshots", ->
      tmp = Path.join process.cwd(), "test/tmp/screenshots"
      FS.mkdirSync tmp, recursive: true
      image = Path.join tmp, "test-screenshot.png"
      pdf = Path.join tmp, "test-screenshot.pdf"
      
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "data:text/html,<h1>Screenshot Test</h1>"
        Mimic.screenshot.image path: image
        Mimic.screenshot.pdf path: pdf
      ]
      
      assert FS.existsSync image
      assert (FS.statSync image).size > 0
      assert FS.existsSync pdf
      assert (FS.statSync pdf).size > 0
      
      [ browser ] = stack
      await browser.close()
      FS.unlinkSync image
      FS.unlinkSync pdf
      FS.rmdirSync tmp

  ]
