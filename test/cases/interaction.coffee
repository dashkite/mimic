import FS from "fs"
import Path from "path"
import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import { pipe } from "@dashkite/joy/function"
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

export default ->
  test "Interaction", [

    test "click, type, clear", ->
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

    test "hover", ->
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

    test "focus", ->
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

    test "blur", ->
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

    test "press", ->
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

    test "scroll", ->
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

    test "submit", ->
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

    test "drag, drop", ->
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

    test "upload", ->
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

  ]
