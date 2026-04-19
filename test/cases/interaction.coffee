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
    Mimic.goto """data:text/html,
      <div id="status">None</div>
      <div id="drag-source" style="width:10px;height:10px;background:red">Source</div>
      <div id="drag-target" style="width:20px;height:20px;background:blue">Target</div>
      <div id="hover-target" style="width:10px;height:10px">Hover Target</div>
      <input id="input-target">
      <button id="button-target" onclick="document.getElementById('status').textContent = 'Clicked'">Click</button>
      <div style="height: 2000px">Spacer</div>
      <form id="form-target" onsubmit="event.preventDefault(); document.getElementById('status').textContent = 'Submitted'">
        <button type="submit">Submit</button>
      </form>
      <script>
        const status = document.getElementById('status');
        const input = document.getElementById('input-target');
        document.getElementById('hover-target').addEventListener('mouseenter', () => status.textContent = 'Hovered');
        input.addEventListener('focus', () => status.textContent = 'Focused');
        input.addEventListener('blur', () => status.textContent = 'Blurred');
        window.addEventListener('keydown', (e) => status.textContent = 'Pressed ' + e.key);
        document.getElementById('drag-target').addEventListener('mouseup', () => status.textContent = 'Dropped');
      </script>
    """
  ]

  test "Interaction", [

    test "click, type, clear", pipe [
      preamble
      Mimic.select "#input-target"
      Mimic.type "Hello Mimic"
      K.drop
      Mimic.select "#button-target"
      Mimic.click
      K.drop
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Clicked"
      K.drop
      K.drop
      Mimic.select "#input-target"
      Mimic.clear
      Mimic.type "New Text"
      K.drop
      Mimic.select "#button-target"
      Mimic.click
      K.drop
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Clicked"
      ([ browser, context ]) -> context.close()
    ]

    test "hover", pipe [
      preamble
      Mimic.select "#hover-target"
      Mimic.hover
      K.drop
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Hovered"
      ([ browser, context ]) -> context.close()
    ]

    test "focus", pipe [
      preamble
      Mimic.select "#input-target"
      Mimic.focus
      K.drop
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Focused"
      ([ browser, context ]) -> context.close()
    ]

    test "blur", pipe [
      preamble
      Mimic.select "#input-target"
      Mimic.focus
      Mimic.blur
      K.drop
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Blurred"
      ([ browser, context ]) -> context.close()
    ]

    test "press", pipe [
      preamble
      Mimic.press "Enter"
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Pressed Enter"
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
      Mimic.select "#form-target"
      Mimic.submit
      K.drop
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Submitted"
      ([ browser, context ]) -> context.close()
    ]

    test "drag, drop", pipe [
      preamble
      Mimic.select "#drag-source"
      Mimic.drag
      K.drop
      Mimic.select "#drag-target"
      Mimic.drop
      K.drop
      Mimic.sleep 100
      Mimic.select "#status"
      Mimic.text
      K.peek ( texts ) -> assert.equal texts[0], "Dropped"
      ([ browser, context ]) -> context.close()
    ]

    test "upload", pipe [
      preamble
      Mimic.evaluate -> 
        input = document.createElement 'input'
        input.type = 'file'
        input.id = 'file-input'
        document.body.appendChild input
      K.drop
      Mimic.select "#file-input"
      Mimic.upload do ->
        tmp = Path.join process.cwd(), "test/tmp/upload"
        FS.mkdirSync tmp, recursive: true
        path = Path.join tmp, "test-upload.txt"
        FS.writeFileSync path, "Upload Test Content"
        path
      K.drop
      Mimic.evaluate -> document.getElementById('file-input').files[0].name
      K.peek ( name ) -> 
        assert.equal name, "test-upload.txt"
        tmp = Path.join process.cwd(), "test/tmp/upload"
        path = Path.join tmp, "test-upload.txt"
        FS.unlinkSync path
        FS.rmdirSync tmp
      ([ browser, context ]) -> context.close()
    ]

  ]
