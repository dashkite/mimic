import puppeteer from "puppeteer"
import locateChrome from "locate-chrome"
import * as _ from "@dashkite/joy"
import * as k from "@dashkite/katana"

# capitalized because we export assert
import Assert from "assert/strict"

isNode = (node) -> node?.$?
nodeOrPage = k.test (_.negate isNode), k.read "page"

# TODO optimized for using global Chrome
#      if we switch back to using local Chrome
#      we don't need to create an incognito
#      instance and we would call close instead
#      of disconnect / see #3
connect = _.flow [
  locateChrome
  (path) -> puppeteer.launch executablePath: path
]

disconnect = (browser) -> browser.disconnect()

launch = (browser, actions) ->
  _.flow [
    -> { browser }
    actions...
  ]

_page = (browser) ->
  do ({page} = {}) ->
    # console.log {browser}
    page = await browser.newPage()
    page.on "console", (message) ->
      console.log "<#{page.url()}>", message.text()
    page.on "pageerror", (error) ->
      console.error "<#{page.url()}>", error
    page

page = k.assign [
  k.read "browser"
  k.poke _page
  k.write "page"
]

page._ = _page


_goto = _.curry (url, page) -> page.goto url

goto = (url) ->
  _.flow [
    k.read "page"
    k.pop _goto url
  ]

goto._ = _goto

sleep = (ms) -> k.peek -> new Promise (resolve) -> setTimeout resolve, ms

pause = sleep 100

_screenshot = _.curry (options, page) -> page.screenshot options

screenshot = (options) ->
  _.flow [
    k.read "page"
    k.pop _screenshot options
  ]

screenshot._ = _screenshot


_script = _.curry (options, page) -> page.addScriptTag options

script = (options) ->
  _.flow [
    k.read "page"
    k.pop _script options
  ]

script._ = _script

_defined = _.curry (name, page) ->
  page.evaluate ((name) -> customElements.whenDefined name), name

defined = (name) ->
  _.flow [
    k.read "page"
    k.pop _defined name
  ]

defined._ = _defined

_content = (page) -> page.content()

content = _.flow [
  k.read "page"
  k.poke _content
]

content._ = _content

_setContent = _.curry (html, page) -> page.setContent html

setContent = (html) ->
  _.flow [
    k.read "page"
    k.pop _setContent html
  ]

setContent._ = _setContent

_render = _.curry (html, node) ->
  node.evaluate ((node, html) -> node.innerHTML = html), html

render = (html) -> k.peek _render html

render._ = _render

_select = _.curry (selector, node) -> node.$ selector

select = (selector) ->
  _.flow [
    nodeOrPage
    k.push _select selector
  ]

select._ = _select

_shadow = (node) -> node.evaluateHandle (node) -> node.shadowRoot

shadow = k.push _shadow

shadow._ = _shadow

_evaluate = _.curry (f, node) -> node.evaluate f

evaluate = (f) ->
  _.flow [
    nodeOrPage
    k.push _evaluate f
  ]

evaluate._ = _evaluate

innerHTML = evaluate (body) -> body.innerHTML


_type = _.curry (text, node) -> node.type text

type = (text) -> k.peek _type text

type._ = _type

_press = _.curry (text, node) -> node.press text

press = (text) -> k.pop _press text

press._ = _press


value = _.flow [
  evaluate (node) -> node.value
]

clear = _.flow [
  evaluate (node) -> node.value = ""
]

_click = (node) -> node.click()

click = k.peek _click

click._ = _click


_submit = (form) -> form.evaluate (form) -> form.requestSubmit()

submit = k.pop _submit

submit._ = _submit


_waitFor = _.curry (check, page, node) ->
  if check.constructor == String
    handle = await page.waitForSelector check
  else
    handle = await page.waitForFunction check, {}, node

waitFor = (check) ->
  _.flow [
    k.read "page"
    k.poke _waitFor check
  ]

waitFor._ = _waitFor


_push = _.curry ({state, title, url}, page) ->
  f = (url) -> history.pushState {}, "", url
  page.evaluate f, url

push = (options) ->
  _.flow [
    k.read "page"
    k.pop _push options
  ]

push._ = _push

isAny = (x) -> true
isJSONValue = (x) -> x.jsonValue?

_assert = _.generic
  name: "mimic assert"
  default: (expected, actual) -> Assert.equal actual, expected

_.generic _assert, isAny, isJSONValue,
  (expected, actual) -> Assert.equal actual.jsonValue(), expected

_.generic _assert, _.isString, _.isString,
  (expected, actual) -> Assert.equal (_.trim actual), expected

_.generic _assert, _.isFunction, isAny,
  (expected, actual) -> Assert.equal true, expected actual

_assert = _.curry _.binary _assert

assert = (expected) -> k.pop _assert expected

assert._ = _assert

export {
  connect
  disconnect
  launch
  page

  goto

  sleep
  pause
  screenshot

  content
  setContent
  render
  script

  select
  defined
  shadow

  type
  press
  value
  clear
  click
  submit

  evaluate
  innerHTML
  waitFor
  push

  assert
}
