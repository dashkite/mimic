import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

do ->
  print await test "Mimic", [

    test "Lifecycle (browser, context, page)", ->
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

    test "Navigation and Selection (goto, select, text)", ->
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

    test "Attributes (attribute)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto 'data:text/html,<div id="test-id" class="test-class"></div>'
        Mimic.select "#test-id"
        Mimic.attribute "class"
      ]
      [ browser, ..., value ] = stack
      assert.equal value, "test-class"
      await browser.close()

    test "Emulation Shorthands (agent, viewport)", ->
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

    test "Data Extraction (evaluate)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.evaluate -> 1 + 1
      ]
      [ browser, ..., result ] = stack
      assert.equal result, 2
      await browser.close()

    test "Content (content)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "data:text/html,<span>Test</span>"
        Mimic.content
      ]
      [ browser, ..., html ] = stack
      assert html.includes "<span>Test</span>"
      await browser.close()

    test "Interaction (click, type, clear)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <input id="input">
          <button id="button" onclick="document.getElementById('out').textContent = document.getElementById('input').value">Click</button>
          <div id="out"></div>
        """
        Mimic.select "#input"
        Mimic.type "Hello Mimic"
        ( stack ) -> stack[...-1]
        Mimic.select "#button"
        Mimic.click
        ( stack ) -> stack[...-1]
        Mimic.select "#out"
        Mimic.text
        K.peek ( texts ) -> 
          assert.equal texts[0], "Hello Mimic"
        ( stack ) -> stack[...-2]
        Mimic.select "#input"
        Mimic.clear
        Mimic.type "New Text"
        ( stack ) -> stack[...-1]
        Mimic.select "#button"
        Mimic.click
        ( stack ) -> stack[...-1]
        Mimic.select "#out"
        Mimic.text
        K.peek ( texts ) ->
          assert.equal texts[0], "New Text"
      ]
      [ browser ] = stack
      await browser.close()

    test "Shadow DOM (shadow)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <script>
            customElements.define('test-component', class extends HTMLElement {
              constructor() {
                super();
                this.attachShadow({mode: 'open'}).innerHTML = '<h1>Shadow Content</h1>';
              }
            });
          </script>
          <test-component></test-component>
        """
        Mimic.select "test-component"
        Mimic.shadow
        Mimic.select "h1"
        Mimic.text
      ]
      [ browser, ..., texts ] = stack
      assert.equal texts[0], "Shadow Content"
      await browser.close()

    test "Storage (storage.clear)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "https://httpbin.org/html"
        Mimic.evaluate -> localStorage.setItem "test-key", "test-value"
        ( stack ) -> stack[...-1]
        Mimic.storage.clear
        Mimic.evaluate -> localStorage.getItem "test-key"
      ]
      [ browser, ..., value ] = stack
      assert value == null
      await browser.close()

    test "Visibility (visible)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div class="item">Visible</div>
          <div class="item" style="display:none">Hidden</div>
        """
        Mimic.select ".item"
        Mimic.visible
        Mimic.text
      ]
      [ browser, ..., texts ] = stack
      assert.equal texts.length, 1
      assert.equal texts[0], "Visible"
      await browser.close()

    test "Cookies (cookies.get, cookies.set)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "https://httpbin.org/cookies/set?test-cookie=test-value"
        Mimic.cookies.get
        K.peek ( cookies ) ->
          cookie = cookies.find ( c ) -> c.name == "test-cookie"
          assert.equal cookie.value, "test-value"
        ( stack ) -> stack[...-1]
        Mimic.cookies.set [ name: "another-cookie", value: "another-value", domain: "httpbin.org" ]
        Mimic.cookies.get
        K.peek ( cookies ) ->
          cookie = cookies.find ( c ) -> c.name == "another-cookie"
          assert.equal cookie.value, "another-value"
      ]
      [ browser ] = stack
      await browser.close()

    test "Navigation (reload, back, forward)", ->
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

    test "Wait For (waitFor selector, waitFor function)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="container"></div>
          <script>
            setTimeout(() => {
              document.getElementById('container').innerHTML = '<div id="late">Late</div>';
            }, 500);
          </script>
        """
        Mimic.waitFor "#late"
        Mimic.select "#late"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Late"
        ( stack ) -> stack[...-2]
        Mimic.waitFor -> document.getElementById('container').childElementCount == 1
      ]
      [ browser ] = stack
      await browser.close()

    test "Dialogs (dialog.dismiss)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.dialog.dismiss
        Mimic.evaluate -> confirm "Are you sure?"
        K.peek ( result ) -> assert result == false
      ]
      [ browser ] = stack
      await browser.close()

    test "Network Mocking (mock)", ->
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
        ( stack ) -> stack[...-1]
        Mimic.waitFor -> document.body.textContent.includes "Hello from Mock"
      ]
      [ browser ] = stack
      await browser.close()

    test "Media Emulation (media)", ->
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

    test "Accessibility (accessibility)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <button aria-label="Submit Form">Button</button>
        """
        Mimic.accessibility
        K.peek ( snapshot ) ->
          button = snapshot.children.find ( node ) -> node.name == "Submit Form"
          assert button?
      ]
      [ browser ] = stack
      await browser.close()

  ]

  process.exit if success then 0 else 1
