import assert from "assert/strict"
import * as a from "amen"

import express from "express"
import files from "express-static"
import * as _ from "@dashkite/joy"
import * as k from "@dashkite/katana"

# module under test
import * as $ from "../src"

do ->

  browser = await $.connect()

  a.print await a.test "Mimic", [

    a.test
      description: "select (launch, page, goto, innerHTML, assert)"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.select "body"
        $.innerHTML
        $.assert ""
      ]

    a.test
      description: "script (pause, evaluate)"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.script content: "window.greeting = 'Hello, world!'"
        $.pause
        $.evaluate -> window.greeting
        $.assert "Hello, world!"
      ]

    a.test
      description: "content (assert fn)"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.content
        $.assert (actual) -> actual.startsWith "<html>"
      ]

    a.test
      description: "set content"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.setContent """
          <html>
            <body>Hello?</body>
          </html>
          """
        $.pause
        $.select "body"
        $.innerHTML
        $.assert "Hello?"
      ]

    a.test
      description: "render"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.select "body"
        $.render "Hola, todo el mundo!"
        $.innerHTML
        $.assert "Hola, todo el mundo!"
      ]

    a.test
      description: "shadow (defined)"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.script content: """
          class Foo extends HTMLElement {
            constructor() {
              super();
              let shadow = this.attachShadow({mode: 'open'});
              let p = document.createElement("p");
              p.innerText = "Hello, world!";
              shadow.appendChild(p);
            }
          }
          customElements.define('x-foo', Foo);
          """
        $.pause
        $.select "body"
        $.render "<x-foo></x-foo>"
        $.defined "x-foo"
        $.select "x-foo"
        $.shadow
        $.select "p"
        $.innerHTML
        $.assert "Hello, world!"
      ]

    a.test
      description: "type (value)"
      wait: false
      $.launch browser, [
        $.page
        $.goto "about:blank"
        $.select "body"
        $.render """
          <form>
            <input type='text'/>
          </form>
          """
        $.pause
        $.select "input"
        $.type "Hello, world!"
        $.select "input"
        $.value
        $.assert "Hello, world!"
      ]

    a.test "waitFor"

    a.test "push"
  ]

  await $.disconnect browser

  process.exit 0
