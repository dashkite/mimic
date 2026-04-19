import FS from "fs"
import Path from "path"
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
        K.drop
        Mimic.select "#button"
        Mimic.click
        K.drop
        Mimic.select "#out"
        Mimic.text
        K.peek ( texts ) -> 
          assert.equal texts[0], "Hello Mimic"
        ( stack ) -> stack[...-2]
        Mimic.select "#input"
        Mimic.clear
        Mimic.type "New Text"
        K.drop
        Mimic.select "#button"
        Mimic.click
        K.drop
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
        K.drop
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
        K.drop
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
        K.drop
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

    test "Clock (clock.tick)", ->
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

    test "Drag and Drop (drag, drop)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="source" style="width:50px;height:50px;background:red">Source</div>
          <div id="target" style="width:100px;height:100px;background:blue;margin-top:20px">Target</div>
          <script>
            const source = document.getElementById('source');
            const target = document.getElementById('target');
            target.addEventListener('mouseup', () => {
              target.textContent = 'Dropped';
            });
          </script>
        """
        Mimic.select "#source"
        Mimic.drag
        K.drop
        Mimic.select "#target"
        Mimic.drop
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Dropped"
      ]
      [ browser ] = stack
      await browser.close()

    test "Upload (upload)", ->
      tmp = Path.join process.cwd(), "test/tmp/upload"
      FS.mkdirSync tmp, recursive: true
      path = Path.join tmp, "test-upload.txt"
      FS.writeFileSync path, "Upload Test Content"
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <input type="file" id="file-input">
        """
        Mimic.select "#file-input"
        Mimic.upload path
        K.drop
        Mimic.evaluate -> document.getElementById('file-input').files[0].name
        K.peek ( name ) -> assert.equal name, "test-upload.txt"
      ]
      [ browser ] = stack
      await browser.close()
      FS.unlinkSync path
      FS.rmdirSync tmp

    test "Interaction (hover)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="status">None</div>
          <div id="target" style="width:10px;height:10px">Target</div>
          <script>
            document.getElementById('target').addEventListener('mouseenter', () => 
              document.getElementById('status').textContent = 'Hovered'
            );
          </script>
        """
        Mimic.select "#target"
        Mimic.hover
        K.drop
        Mimic.select "#status"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Hovered"
      ]
      [ browser ] = stack
      await browser.close()

    test "Interaction (focus)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="status">None</div>
          <input id="target">
          <script>
            document.getElementById('target').addEventListener('focus', () => 
              document.getElementById('status').textContent = 'Focused'
            );
          </script>
        """
        Mimic.select "#target"
        Mimic.focus
        K.drop
        Mimic.select "#status"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Focused"
      ]
      [ browser ] = stack
      await browser.close()

    test "Interaction (blur)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="status">None</div>
          <input id="target">
          <script>
            document.getElementById('target').addEventListener('blur', () => 
              document.getElementById('status').textContent = 'Blurred'
            );
          </script>
        """
        Mimic.select "#target"
        Mimic.focus
        Mimic.blur
        K.drop
        Mimic.select "#status"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Blurred"
      ]
      [ browser ] = stack
      await browser.close()

    test "Interaction (press)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="status">None</div>
          <script>
            window.addEventListener('keydown', (e) => 
              document.getElementById('status').textContent = 'Pressed ' + e.key
            );
          </script>
        """
        Mimic.press "Enter"
        Mimic.select "#status"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Pressed Enter"
      ]
      [ browser ] = stack
      await browser.close()

    test "Interaction (scroll)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div style="height: 2000px">Spacer</div>
        """
        Mimic.scroll "bottom"
        Mimic.evaluate -> window.scrollY > 0
        K.peek ( scrolled ) -> assert scrolled
      ]
      [ browser ] = stack
      await browser.close()

    test "Interaction (submit)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto """data:text/html,
          <div id="status">None</div>
          <form id="form" onsubmit="event.preventDefault(); document.getElementById('status').textContent = 'Submitted'">
            <button type="submit">Submit</button>
          </form>
        """
        Mimic.select "#form"
        Mimic.submit
        K.drop
        Mimic.select "#status"
        Mimic.text
        K.peek ( texts ) -> assert.equal texts[0], "Submitted"
      ]
      [ browser ] = stack
      await browser.close()

    test "Dialogs (dialog.accept)", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.dialog.accept
        Mimic.evaluate -> confirm "Are you sure?"
        K.peek ( result ) -> assert result == true
      ]
      [ browser ] = stack
      await browser.close()

    test "Screenshots (screenshot.image, screenshot.pdf)", ->
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

  process.exit if success then 0 else 1
