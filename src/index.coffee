import {wrap, arity, flip, curry, flow} from "@pandastrike/garden"
import {
  push, pop, peek, poke
  read, write, discard
  branch, log
} from "@dashkite/katana"

import assert from "assert"

_page = curry (url, {browser}) ->
  do ({page} = {}) ->
    page = await browser.newPage()
    page.on "console", (message) -> console.log "<#{url}>", message.text()
    page.on "pageerror", (error) -> console.error "<#{url}>", error
    await page.goto url
    page

page = (url) ->
  flow [
    push _page url
    write "page"
    discard
  ]

_defined = curry (name, page) ->
  page.evaluate ((name) -> customElements.whenDefined name), name

defined = (name) ->
  flow [
    read "page"
    pop _defined name
  ]

# TODO generalize this for any node?
_render = curry (html, page) ->
  page.evaluate ((html) -> document.body.innerHTML = html), html

render = (html) ->
  flow [
    read "page"
    pop _render html
  ]

_select = curry (selector, node) -> node.$ selector

select = (selector) ->
  flow [
    branch [
      [ ((node) -> node.$?), push _select selector ]
      [ (wrap true), flow [ (read "page"), poke _select selector ] ]
    ]
  ]

_shadow = (node) -> node.evaluateHandle (node) -> node.shadowRoot

shadow = push _shadow

sleep = (ms) -> peek -> new Promise (resolve) -> setTimeout resolve, ms

pause = sleep 100

_evaluate = curry (f, node) -> node.evaluate f

evaluate = (f) ->
  flow [
    branch [
      [ ((node) -> node.evaluate?), push _evaluate f ]
      [ (wrap true), flow [ (read "page"), poke _evaluate f ] ]
    ]
  ]

_waitFor = curry (check, page, node) ->
  handle = await page.waitForFunction check, {}, node
  handle.jsonValue()

waitFor = (check) ->
  flow [
    read "page"
    poke _waitFor check
  ]

_equal = curry (expected, actual) -> assert.equal expected, actual

equal = (expected) -> pop _equal expected

clear = flow [
  evaluate (node) -> node.value = ""
  discard
]

_type = curry (text, node) -> node.type text

type = (text) -> pop _type text

_submit = (form) -> form.evaluate (form) -> form.requestSubmit()

submit = pop _submit

# TODO there has to be a better way ...
Metal =
  page: _page
  defined: _defined
  render: _render
  select: _select
  shadow: _shadow
  type: _type
  submit: _submit
  waitFor: _waitFor
  equal: _equal

export { page, defined, render, select, shadow,
  sleep, pause, clear, type, submit, evaluate, waitFor, equal,
  Metal}
