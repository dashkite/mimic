import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ->
  test "Inspection & Selection", [

    test "attribute", ->
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

    test "evaluate", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.evaluate -> 1 + 1
      ]
      [ browser, ..., result ] = stack
      assert.equal result, 2
      await browser.close()

    test "content", ->
      stack = await do pipe [
        Mimic.browser()
        Mimic.page
        Mimic.goto "data:text/html,<span>Test</span>"
        Mimic.content
      ]
      [ browser, ..., html ] = stack
      assert html.includes "<span>Test</span>"
      await browser.close()

    test "shadow", ->
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

    test "visible", ->
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

    test "waitFor", ->
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

    test "accessibility", ->
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
