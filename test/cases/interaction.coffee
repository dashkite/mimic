import FS from "fs"
import Path from "path"
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
    Mimic.goto """data:text/html,
      <div id="status">None</div>
      <div id="drag-source" 
        style="width:10px;height:10px;background:red">Source</div>
      <div id="drag-target" 
        style="width:20px;height:20px;background:blue">Target</div>
      <div id="hover-target" 
        style="width:10px;height:10px">Hover Target</div>
      <input id="input-target">
      <button id="button-target" 
        onclick="document.getElementById('status').textContent = 'Clicked'">
        Click
      </button>
      <div style="height: 2000px">Spacer</div>
      <form id="form-target" 
        onsubmit="event.preventDefault(); 
          document.getElementById('status').textContent = 'Submitted'">
        <button type="submit">Submit</button>
      </form>
      <script>
        const status = document.getElementById('status');
        const input = document.getElementById('input-target');
        document.getElementById('hover-target')
          .addEventListener('mouseenter', () => status.textContent = 'Hovered');
        input.addEventListener('focus', () => status.textContent = 'Focused');
        input.addEventListener('blur', () => status.textContent = 'Blurred');
        window.addEventListener('keydown', 
          (e) => status.textContent = 'Pressed ' + e.key);
        document.getElementById('drag-target')
          .addEventListener('mouseup', () => status.textContent = 'Dropped');
      </script>
    """
  ]

  test "Interaction", [

    test "click, type, clear", pipe [
      preamble
      tee pipe [
        Mimic.select "#input-target"
        Mimic.type "Hello Mimic"
      ]
      tee pipe [
        Mimic.select "#button-target"
        Mimic.click
      ]
      tee pipe [
        Mimic.select "#status"
        Mimic.text
        K.peek ([ value ]) -> assert.equal value, "Clicked"
      ]
      tee pipe [
        Mimic.select "#input-target"
        Mimic.clear
        Mimic.type "New Text"
      ]
      tee pipe [
        Mimic.select "#button-target"
        Mimic.click
      ]
      tee pipe [
        Mimic.select "#status"
        Mimic.text
        K.peek ([ value ]) -> assert.equal value, "Clicked"
      ]
      ([ browser, context ]) -> context.close()
    ]

    test "hover", pipe [
      preamble
      tee pipe [
        Mimic.select "#hover-target"
        Mimic.hover
      ]
      Mimic.select "#status"
      Mimic.text
      K.peek ([ value ]) -> assert.equal value, "Hovered"
      ([ browser, context ]) -> context.close()
    ]

    test "focus", pipe [
      preamble
      tee pipe [
        Mimic.select "#input-target"
        Mimic.focus
      ]
      Mimic.select "#status"
      Mimic.text
      K.peek ([ value ]) -> assert.equal value, "Focused"
      ([ browser, context ]) -> context.close()
    ]

    test "blur", pipe [
      preamble
      tee pipe [
        Mimic.select "#input-target"
        Mimic.focus
        Mimic.blur
      ]
      Mimic.select "#status"
      Mimic.text
      K.peek ([ value ]) -> assert.equal value, "Blurred"
      ([ browser, context ]) -> context.close()
    ]

    test "press", pipe [
      preamble
      Mimic.press "Enter"
      Mimic.select "#status"
      Mimic.text
      K.peek ([ value ]) -> assert.equal value, "Pressed Enter"
      ([ browser, context ]) -> context.close()
    ]

    test "scroll", pipe [
      preamble
      Mimic.scroll "bottom"
      Mimic.evaluate -> window.scrollY > 0
      K.peek ( scrolled ) -> assert scrolled
      ([ browser, context ]) -> context.close()
    ]

    test "submit", pipe [
      preamble
      tee pipe [
        Mimic.select "#form-target"
        Mimic.submit
      ]
      Mimic.select "#status"
      Mimic.text
      K.peek ([ value ]) -> assert.equal value, "Submitted"
      ([ browser, context ]) -> context.close()
    ]

    test "drag, drop", pipe [
      preamble
      tee pipe [
        Mimic.select "#drag-source"
        Mimic.drag
      ]
      tee pipe [
        Mimic.select "#drag-target"
        Mimic.drop
      ]
      Mimic.sleep 100
      Mimic.select "#status"
      Mimic.text
      K.peek ([ value ]) -> assert.equal value, "Dropped"
      ([ browser, context ]) -> context.close()
    ]

    test "upload", pipe [
      preamble
      tee pipe [
        Mimic.evaluate -> 
          input = document.createElement 'input'
          input.type = 'file'
          input.id = 'file-input'
          document.body.appendChild input
      ]
      tee pipe [
        Mimic.select "#file-input"
        Mimic.upload do ->
          tmp = Path.join process.cwd(), "test/tmp/upload"
          FS.mkdirSync tmp, recursive: true
          path = Path.join tmp, "test-upload.txt"
          FS.writeFileSync path, "Upload Test Content"
          path
      ]
      Mimic.evaluate -> 
        document.getElementById('file-input').files[0].name
      K.peek ( name ) -> 
        assert.equal name, "test-upload.txt"
        tmp = Path.join process.cwd(), "test/tmp/upload"
        path = Path.join tmp, "test-upload.txt"
        FS.unlinkSync path
        FS.rmdirSync tmp
      ([ browser, context ]) -> context.close()
    ]

  ]
