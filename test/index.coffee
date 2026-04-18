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
        K.drop
        K.drop
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

  ]

  process.exit if success then 0 else 1
