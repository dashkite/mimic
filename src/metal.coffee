import Generic from "@dashkite/generic"
import * as Time from "@dashkite/joy/time"
import { isKind } from "@dashkite/joy/type"
import {
  Page
  BrowserContext
  ElementHandle
  JSHandle
} from "puppeteer"

# -- Predicates --

isPage = isKind Page
isTarget = ( x ) -> ( isKind Page, x ) || ( isKind JSHandle, x )

# -- Generic Dispatchers --

# select
export select = Generic.make
  name: "Mimic.select"
  default: ( target ) -> 
    throw new Error "select: expected Page, ElementHandle, or ShadowRoot handle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have a valid context for querying."

select.define [ isPage, String ], ( page, selector ) -> 
  page.$$ selector

select.define [ ElementHandle, String ], ( element, selector ) -> 
  element.$$ selector

select.define [ JSHandle, String ], ( handle, selector ) ->
  list = await handle.evaluateHandle ( ( node, selector ) -> 
    node.querySelectorAll selector
  ), selector
  properties = await list.getProperties()
  handles = []
  for [ _, prop ] from properties
    if ( element = prop.asElement() )?
      handles.push element
  handles

# shadow
export shadow = Generic.make
  name: "Mimic.shadow"
  default: ( target ) ->
    throw new Error "shadow: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have selected an element and refined the context 
      with 'first' if necessary."

shadow.define [ ElementHandle ], ( element ) ->
  root = await element.evaluateHandle ( node ) -> node.shadowRoot
  isNull = await root.evaluate ( node ) -> node == null
  if isNull
    throw new Error "shadow: element has no shadowRoot.
      Ensure the component has initialized and attached its shadow DOM."
  root

shadow.define [ Array ], ( elements ) -> shadow elements[0]

# type
export type = Generic.make
  name: "Mimic.type"
  default: ( target ) ->
    throw new Error "type: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have selected the specific input element 
      you wish to type into."

type.define [ ElementHandle, String ], ( element, text ) ->
  await element.focus()
  await element.evaluate ( node ) -> node.value = ""
  element.type text

type.define [ Array, String ], ( elements, text ) -> type elements[0], text

# click
export click = Generic.make
  name: "Mimic.click"
  default: ( target ) ->
    throw new Error "click: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ].
      Ensure you have selected the specific element you wish to click."

click.define [ ElementHandle ], ( element ) -> 
  element.click()

click.define [ Array ], ( elements ) -> click elements[0]

# attribute
export attribute = Generic.make
  name: "Mimic.attribute"
  default: ( target ) ->
    throw new Error "attribute: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

attribute.define [ ElementHandle, String ], ( element, name ) ->
  element.evaluate ( ( node, name ) -> node.getAttribute name ), name

attribute.define [ Array, String ], ( elements, name ) ->
  attribute elements[0], name

# evaluate
export evaluate = Generic.make
  name: "Mimic.evaluate"
  default: ( target ) ->
    throw new Error "evaluate: expected Page or Handle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

evaluate.define [ isPage, Function ], ( page, f ) -> 
  page.evaluate f

evaluate.define [ JSHandle, Function ], ( handle, f ) -> 
  handle.evaluate f

# wait
export wait = Generic.make
  name: "Mimic.wait"
  default: ( target ) ->
    throw new Error "wait: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

wait.define [ isPage, Object ], ( page, options ) ->
  page.waitForNetworkIdle do ->
    Object.assign { idleTime: 500, timeout: 10000 }, options

# waitFor
export waitFor = Generic.make
  name: "Mimic.waitFor"
  default: ( target ) ->
    throw new Error "waitFor: expected Page or Handle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

waitFor.define [ isTarget, String, Object ], ( target, selector, options ) ->
  options.timeout ?= 10000
  target.waitForSelector selector, options

waitFor.define [ isTarget, Function, Object ],
  ( target, condition, options ) ->
    options.timeout ?= 10000
    target.waitForFunction condition, options

# screenshot
export screenshot =
  image: Generic.make
    name: "Mimic.screenshot.image"
    default: ( target ) ->
      throw new Error "screenshot.image: expected Page or ElementHandle,
        but received [ #{ target?.constructor?.name ? typeof target } ]."
  pdf: Generic.make
    name: "Mimic.screenshot.pdf"
    default: ( target ) ->
      throw new Error "screenshot.pdf: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

screenshot.image.define [ isPage, Object ], ( page, options ) ->
  page.screenshot options

screenshot.image.define [ ElementHandle, Object ], ( element, options ) ->
  element.screenshot options

screenshot.pdf.define [ isPage, Object ], ( page, options ) ->
  page.pdf options

# cookies
export cookies =
  get: Generic.make
    name: "Mimic.cookies.get"
    default: ( target ) ->
      throw new Error "cookies.get: expected Page or BrowserContext,
        but received [ #{ target?.constructor?.name ? typeof target } ]."
  set: Generic.make
    name: "Mimic.cookies.set"
    default: ( target ) ->
      throw new Error "cookies.set: expected Page or BrowserContext,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

cookies.get.define [ isPage ], ( page ) -> page.cookies()
cookies.get.define [ BrowserContext ], ( context ) -> context.cookies()

cookies.set.define [ isPage, Array ], ( page, cookies ) -> 
  page.setCookie ...cookies

cookies.set.define [ BrowserContext, Array ], ( context, cookies ) ->
  context.setCookie ...cookies

# viewport
export viewport = Generic.make
  name: "Mimic.viewport"
  default: ( target ) ->
    throw new Error "viewport: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

viewport.define [ isPage, Object ], ( page, options ) ->
  page.setViewport options

# emulate
export emulate = Generic.make
  name: "Mimic.emulate"
  default: ( target, device ) ->
    throw new Error "emulate: expected Page and either String or Object,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ device?.constructor?.name ? typeof device } ]."

emulate.define [ isPage, String ], ( page, userAgent ) ->
  page.setUserAgent userAgent

emulate.define [ isPage, Object ], ( page, device ) ->
  page.emulate device

# media
export media = Generic.make
  name: "Mimic.media"
  default: ( target ) ->
    throw new Error "media: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

media.define [ isPage, String ], ( page, type ) ->
  page.emulateMediaType type

media.define [ isPage, String, Array ], ( page, type, features ) ->
  await page.emulateMediaType type
  page.emulateMediaFeatures features

# navigation
export goto = Generic.make
  name: "Mimic.goto"
  default: ( target, url, options ) ->
    throw new Error "goto: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ url?.constructor?.name ? typeof url } ]."

goto.define [ isPage, String, Object ], ( page, url, options ) ->
  page.goto url, options

export reload = Generic.make
  name: "Mimic.reload"
  default: ( target ) ->
    throw new Error "reload: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

reload.define [ isPage ], ( page ) ->
  page.reload waitUntil: "networkidle2"

export back = Generic.make
  name: "Mimic.back"
  default: ( target ) ->
    throw new Error "back: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

back.define [ isPage ], ( page ) ->
  page.goBack waitUntil: "networkidle2"

export forward = Generic.make
  name: "Mimic.forward"
  default: ( target ) ->
    throw new Error "forward: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

forward.define [ isPage ], ( page ) ->
  page.goForward waitUntil: "networkidle2"

# interaction
export upload = Generic.make
  name: "Mimic.upload"
  default: ( target ) ->
    throw new Error "upload: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

upload.define [ ElementHandle, Array ], ( element, paths ) ->
  element.uploadFile ...paths

upload.define [ Array, Array ], ( elements, paths ) ->
  upload elements[0], paths

export drag = Generic.make
  name: "Mimic.drag"
  default: ( target ) ->
    throw new Error "drag: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

drag.define [ ElementHandle ], ( element ) ->
  box = await element.boundingBox()
  x = box.x + box.width / 2
  y = box.y + box.height / 2
  await element.frame().page().mouse.move x, y
  element.frame().page().mouse.down()

drag.define [ Array ], ( elements ) -> drag elements[0]

export drop = Generic.make
  name: "Mimic.drop"
  default: ( target ) ->
    throw new Error "drop: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

drop.define [ ElementHandle ], ( element ) ->
  box = await element.boundingBox()
  x = box.x + box.width / 2
  y = box.y + box.height / 2
  await element.frame().page().mouse.move x, y
  element.frame().page().mouse.up()

drop.define [ Array ], ( elements ) -> drop elements[0]

# inspection
export visible = Generic.make
  name: "Mimic.visible"
  default: ( target ) ->
    throw new Error "visible: expected array of ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

visible.define [ Array ], ( elements ) ->
  results = []
  for element in elements
    if await element.isVisible()
      results.push element
  results

export accessibility = Generic.make
  name: "Mimic.accessibility"
  default: ( target ) ->
    throw new Error "accessibility: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

accessibility.define [ isPage ], ( page ) ->
  page.accessibility.snapshot()

export agent = Generic.make
  name: "Mimic.agent"
  default: ( target, agent ) ->
    throw new Error "agent: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ agent?.constructor?.name ? typeof agent } ]."

agent.define [ isPage, String ], ( page, agent ) ->
  page.setUserAgent agent

export content = Generic.make
  name: "Mimic.content"
  default: ( target ) ->
    throw new Error "content: expected Page,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

content.define [ isPage ], ( page ) ->
  page.content()

# mock
export mock = Generic.make
  name: "Mimic.mock"
  default: ( target, pattern, handler ) ->
    throw new Error "mock: expected Page, RegExp, and Function,
      but received [ #{ target?.constructor?.name ? typeof target } ],
      [ #{ pattern?.constructor?.name ? typeof pattern } ],
      and [ #{ handler?.constructor?.name ? typeof handler } ]."

mock.define [ isPage, RegExp, Function ], ( page, pattern, handler ) ->
  page.on "request", ( request ) ->
    if ( request.url().match pattern )
      handler request
    else
      request.continue()
  await page.setRequestInterception true

# clock
export clock =
  tick: Generic.make
    name: "Mimic.clock.tick"
    default: ( target, ms ) ->
      throw new Error "clock.tick: expected Page and Number,
        but received [ #{ target?.constructor?.name ? typeof target } ]
        and [ #{ ms?.constructor?.name ? typeof ms } ]."

clock.tick.define [ isPage, Number ], ( page, ms ) ->
  client = await page.createCDPSession()
  client.send "Emulation.setVirtualTimePolicy",
    policy: "advance"
    budget: ms

# storage
export storage =
  clear: Generic.make
    name: "Mimic.storage.clear"
    default: ( target ) ->
      throw new Error "storage.clear: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

storage.clear.define [ isPage ], ( page ) ->
  page.evaluate ->
    localStorage.clear()
    sessionStorage.clear()

# blur
export blur = Generic.make
  name: "Mimic.blur"
  default: ( target ) ->
    throw new Error "blur: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

blur.define [ ElementHandle ], ( element ) ->
  element.evaluate ( node ) -> node.blur()

blur.define [ Array ], ( elements ) -> blur elements[0]

# dialog
export dialog =
  accept: Generic.make
    name: "Mimic.dialog.accept"
    default: ( target ) ->
      throw new Error "dialog.accept: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."
  dismiss: Generic.make
    name: "Mimic.dialog.dismiss"
    default: ( target ) ->
      throw new Error "dialog.dismiss: expected Page,
        but received [ #{ target?.constructor?.name ? typeof target } ]."

dialog.accept.define [ isPage ], ( page ) ->
  page.on "dialog", ( dialog ) -> dialog.accept()

dialog.dismiss.define [ isPage ], ( page ) ->
  page.on "dialog", ( dialog ) -> dialog.dismiss()

# scroll
export scroll = Generic.make
  name: "Mimic.scroll"
  default: ( target, position ) ->
    throw new Error "scroll: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ position?.constructor?.name ? typeof position } ]."

scroll.define [ isPage, String ], ( page, position ) ->
  if position == "bottom"
    page.evaluate -> window.scrollTo 0, document.body.scrollHeight

# hover
export hover = Generic.make
  name: "Mimic.hover"
  default: ( target ) ->
    throw new Error "hover: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

hover.define [ ElementHandle ], ( element ) ->
  element.hover()

hover.define [ Array ], ( elements ) -> hover elements[0]

# focus
export focus = Generic.make
  name: "Mimic.focus"
  default: ( target ) ->
    throw new Error "focus: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

focus.define [ ElementHandle ], ( element ) ->
  element.focus()

focus.define [ Array ], ( elements ) -> focus elements[0]

# clear
export clear = Generic.make
  name: "Mimic.clear"
  default: ( target ) ->
    throw new Error "clear: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

clear.define [ ElementHandle ], ( element ) ->
  element.evaluate ( node ) -> node.value = ""

clear.define [ Array ], ( elements ) -> clear elements[0]

# press
export press = Generic.make
  name: "Mimic.press"
  default: ( target, key ) ->
    throw new Error "press: expected Page and String,
      but received [ #{ target?.constructor?.name ? typeof target } ]
      and [ #{ key?.constructor?.name ? typeof key } ]."

press.define [ isPage, String ], ( page, key ) ->
  page.keyboard.press key

# submit
export submit = Generic.make
  name: "Mimic.submit"
  default: ( target ) ->
    throw new Error "submit: expected ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

submit.define [ ElementHandle ], ( element ) ->
  element.evaluate ( node ) ->
    if node.requestSubmit
      node.requestSubmit()
    else
      button = node.querySelector 'button[type="submit"], input[type="submit"]'
      if button
        button.click()
      else
        node.submit()

submit.define [ Array ], ( elements ) -> submit elements[0]

# text
export text = Generic.make
  name: "Mimic.text"
  default: ( target ) ->
    throw new Error "text: expected array of ElementHandle,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

text.define [ Array ], ( elements ) ->
  results = []
  for element in elements
    results.push await element.evaluate ( node ) -> node.textContent
  results
