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

  test "Inspection & Selection", [

    test "attribute", pipe [
      preamble
      Mimic.goto 'data:text/html,<div id="test-id" class="test-class"></div>'
      Mimic.select "#test-id"
      Mimic.attribute "class"
      K.peek ( value ) -> assert.equal value, "test-class"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "evaluate", pipe [
      preamble
      Mimic.evaluate -> 1 + 1
      K.peek ( result ) -> assert.equal result, 2
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "content", pipe [
      preamble
      Mimic.goto "data:text/html,<span>Test</span>"
      Mimic.content
      K.peek ( html ) -> assert html.includes "<span>Test</span>"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "shadow", pipe [
      preamble
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
      K.peek ( texts ) -> assert.equal texts[0], "Shadow Content"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "visible", pipe [
      preamble
      Mimic.goto """data:text/html,
        <div class="item">Visible</div>
        <div class="item" style="display:none">Hidden</div>
      """
      Mimic.select ".item"
      Mimic.visible
      Mimic.text
      K.peek ( texts ) ->
        assert.equal texts.length, 1
        assert.equal texts[0], "Visible"
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "waitFor", pipe [
      preamble
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
      K.drop
      K.drop
      Mimic.waitFor -> document.getElementById('container').childElementCount == 1
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

    test "accessibility", pipe [
      preamble
      Mimic.goto """data:text/html,
        <button aria-label="Submit Form">Button</button>
      """
      Mimic.accessibility
      K.peek ( snapshot ) ->
        button = snapshot.children.find ( node ) -> node.name == "Submit Form"
        assert button?
      ( stack ) ->
        [ browser, context ] = stack
        context.close()
    ]

  ]
