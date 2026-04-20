import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe, tee } from "@dashkite/joy/function"
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
      Mimic.goto """data:text/html,
        <div id="test-id" class="test-class"></div>
      """
      tee pipe [
        Mimic.select "#test-id"
        Mimic.attribute "class"
        K.peek ([ value ]) -> assert.equal value, "test-class"
      ]
      ([ browser, context ]) -> context.close()
    ]

    test "evaluate", pipe [
      preamble
      tee pipe [
        Mimic.evaluate -> 1 + 1
        K.peek ( result ) -> assert.equal result, 2
      ]
      ([ browser, context ]) -> context.close()
    ]

    test "content", pipe [
      preamble
      Mimic.goto "data:text/html,<span>Test</span>"
      tee pipe [
        Mimic.content
        K.peek ( html ) -> assert html.includes "<span>Test</span>"
      ]
      ([ browser, context ]) -> context.close()
    ]

    test "shadow", pipe [
      preamble
      Mimic.goto """data:text/html,
        <script>
          customElements.define('test-component',
            class extends HTMLElement {
              constructor() {
                super();
                this.attachShadow({mode: 'open'}).innerHTML = 
                  '<h1>Shadow Content</h1>';
              }
            });
        </script>
        <test-component></test-component>
      """
      tee pipe [
        Mimic.select "test-component"
        Mimic.shadow
        Mimic.select "h1"
        Mimic.text
        K.peek ([ title ]) -> assert.equal title, "Shadow Content"
      ]
      ([ browser, context ]) -> context.close()
    ]

    test "waitForShadow", pipe [
      preamble
      Mimic.goto """data:text/html,
        <script>
          setTimeout(() => {
            customElements.define('delayed-component', 
              class extends HTMLElement {
                constructor() {
                  super();
                  this.attachShadow({mode: 'open'})
                    .innerHTML = '<h1>Late Shadow</h1>';
                }
              });
            document.body.innerHTML = 
              '<delayed-component></delayed-component>';
          }, 500);
        </script>
      """
      Mimic.waitFor "delayed-component"
      Mimic.select "delayed-component"
      Mimic.waitForShadow
      Mimic.shadow
      Mimic.select "h1"
      Mimic.text
      K.peek ([ text ]) -> assert.equal text, "Late Shadow"
      ([ browser, context ]) -> context.close()
    ]

    test "visible", pipe [
      preamble
      Mimic.goto """data:text/html,
        <div class="item">Visible</div>
        <div class="item" style="display:none">Hidden</div>
      """
      tee pipe [
        Mimic.select ".item"
        Mimic.visible
        Mimic.text
        K.peek ([ text ]) ->
          assert.equal text, "Visible"
      ]
      ([ browser, context ]) -> context.close()
    ]

    test "waitFor", pipe [
      preamble
      Mimic.goto """data:text/html,
        <div id="container"></div>
        <script>
          setTimeout(() => {
            document.getElementById('container').innerHTML = 
              '<div id="late">Late</div>';
          }, 500);
        </script>
      """
      tee pipe [
        Mimic.waitFor "#late"
        Mimic.select "#late"
        Mimic.text
        K.peek ([ text ]) -> assert.equal text, "Late"
      ]
      Mimic.waitFor -> 
        document.getElementById('container').childElementCount == 1
      ([ browser, context ]) -> context.close()
    ]

    test "accessibility", pipe [
      preamble
      Mimic.goto """data:text/html,
        <button aria-label="Submit Form">Button</button>
      """
      tee pipe [
        Mimic.accessibility
        K.peek ( snapshot ) ->
          button = snapshot.children.find ( node ) -> 
            node.name == "Submit Form"
          assert button?
      ]
      ([ browser, context ]) -> context.close()
    ]

  ]
