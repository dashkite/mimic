import {wrap, arity, flip, curry, flow} from "@pandastrike/garden"
import * as k from "@dashkite/katana"

import assert from "assert"


_browser = (puppeteer) -> puppeteer.launch()

browser = (puppeteer) ->
  flow [
    wrap [ puppeteer, {} ]
    k.poke _browser
    k.write "browser"
    k.discard
  ]

browser._ = _browser

_page = curry (browser) ->
  do ({page} = {}) ->
    page = await browser.newPage()
    page.on "console", (message) ->
      console.log "<#{page.url()}>", message.text()
    page.on "pageerror", (error) ->
      console.error "<#{page.url()}>", error
    page

page = flow [
  k.read "browser"
  k.poke _page
  k.write "page"
  k.discard
]

page._ = _page


_goto = curry (url, page) -> page.goto url

goto = (url) ->
  flow [
    k.read "page"
    k.pop _goto url
  ]

goto._ = _goto


_screenshot = curry (options, page) -> page.screenshot options

screenshot = (options) ->
  flow [
    k.read "page"
    k.pop _screenshot options
  ]

screenshot._ = _screenshot


_script = curry (options, page) -> page.addScriptTag options

script = (options) ->
  flow [
    k.read "page"
    k.pop _script options
  ]

script._ = _script


_defined = curry (name, page) ->
  page.evaluate ((name) -> customElements.whenDefined name), name

defined = (name) ->
  flow [
    k.read "page"
    k.pop _defined name
  ]

defined._ = _defined


_getHTML = (page) -> page.content()

getHTML = flow [
  k.read "page"
  k.poke _getHTML
]

getHTML._ = _getHTML


_setHTML = curry (html, page) -> page.setContent html

setHTML = (html) ->
  flow [
    k.read "page"
    k.pop _setHTML html
  ]

setHTML._ = _setHTML


# TODO generalize this for any node?
_render = curry (html, page) ->
  page.evaluate ((html) -> document.body.innerHTML = html), html

render = (html) ->
  flow [
    k.read "page"
    k.pop _render html
  ]

render._ = _render


_select = curry (selector, node) -> node.$ selector

select = (selector) ->
  flow [
    k.branch [
      [ ((node) -> node.$?), k.push _select selector ]
      [ (wrap true), flow [ (k.read "page"), k.poke _select selector ] ]
    ]
  ]

select._ = _select

_shadow = (node) -> node.evaluateHandle (node) -> node.shadowRoot

shadow = k.push _shadow

shadow._ = _shadow


sleep = (ms) -> k.peek -> new Promise (resolve) -> setTimeout resolve, ms

pause = sleep 100


_evaluate = curry (f, node) -> node.evaluate f

evaluate = (f) ->
  flow [
    k.branch [
      [ ((node) -> node.evaluate?), k.push _evaluate f ]
      [ (wrap true), flow [ (k.read "page"), k.poke _evaluate f ] ]
    ]
  ]

evaluate._ = _evaluate


_push = curry ({state, title, url}, page) ->
  f = (url) -> history.pushState {}, "", url
  page.evaluate f, url

push = (options) ->
  flow [
    k.read "page"
    k.pop _push options
  ]

push._ = _push


_waitFor = curry (check, page, node) ->
  if check.constructor == String
    handle = await page.waitForSelector check
  else
    handle = await page.waitForFunction check, {}, node

waitFor = (check) ->
  flow [
    k.read "page"
    k.poke _waitFor check
  ]

waitFor._ = _waitFor


_equal = curry (expected, actual) ->
  if actual.jsonValue?
    actual = await actual.jsonValue()
  assert.equal expected, actual

equal = (expected) -> k.pop _equal expected

equal._ = _equal


clear = flow [
  evaluate (node) -> node.value = ""
  k.discard
]




_type = curry (text, node) -> node.type text

type = (text) -> k.peek _type text

type._ = _type


_press = curry (text, node) -> node.press text

press = (text) -> k.pop _press text

press._ = _press


_click = (node) -> node.click()

click = k.peek _click

click._ = _click


_submit = (form) -> form.evaluate (form) -> form.requestSubmit()

submit = k.pop _submit

submit._ = _submit


export {
  browser
  page

  goto
  push

  sleep
  pause
  screenshot

  getHTML
  setHTML
  render
  script

  select
  defined
  shadow

  clear
  type
  press
  click
  submit

  evaluate
  waitFor

  equal
}
