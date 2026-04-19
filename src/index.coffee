import * as K from "@dashkite/katana"
import * as Time from "@dashkite/joy/time"
import puppeteer from "puppeteer"
import * as _ from "./metal"
import Agents from "./agents"

# -- Helpers --

resolve = ( shorthand ) -> Agents[shorthand] ? shorthand

# -- Public API --

Mimic =

  # Context Management
  #
  # Katana Protocol:
  # - Combinators that transform context use K.push
  # - Combinators that interact with context use K.peek

  browser: _.browser
  close: K.peek ( target ) -> _.close target
  context: K.push ( browser ) -> browser.createBrowserContext()
  page: K.push ( context ) -> context.newPage()

  # Configuration (Peek)
  agent: ( agent ) ->
    K.peek ( page ) -> _.agent page, ( resolve agent )

  console: ( handler ) ->
    K.peek ( page ) -> page.on "console", handler

  error: ( handler ) ->
    K.peek ( page ) -> page.on "pageerror", handler

  mock: ( pattern, handler ) ->
    K.peek ( page ) -> _.mock page, pattern, handler

  # Clock (Peek)
  clock:
    tick: ( ms ) -> K.peek ( page ) -> _.clock.tick page, ms

  # Storage (Peek)
  storage:
    clear: K.peek ( page ) -> _.storage.clear page

  # Dialog (Peek)
  dialog:
    accept: K.peek ( page ) -> _.dialog.accept page
    dismiss: K.peek ( page ) -> _.dialog.dismiss page

  # Emulation (Peek)
  viewport: ( options ) -> K.peek ( page ) -> _.viewport page, ( resolve options )
  emulate: ( device ) ->
    K.peek ( page ) -> _.emulate page, ( resolve device )
  media: ( type, features ) ->
    K.peek ( page ) -> 
      if features?
        _.media page, type, features
      else
        _.media page, type

  # Cookies (Push/Peek)
  cookies:
    get: K.push ( target ) -> _.cookies.get target
    set: ( cookies ) -> K.peek ( target ) -> _.cookies.set target, cookies

  # Navigation (Peek)
  reload: K.peek ( page ) -> _.reload page
  back: K.peek ( page ) -> _.back page
  forward: K.peek ( page ) -> _.forward page
  goto: ( url, options = {} ) -> 
    options.waitUntil ?= "networkidle2"
    K.peek ( page ) -> _.goto page, url, options

  # Synchronization (Peek)
  wait: ( options = {} ) -> K.peek ( target ) -> _.wait target, options

  sleep: ( ms ) -> K.peek -> Time.sleep ms

  waitFor: ( condition, options = {} ) -> 
    K.peek ( target ) -> _.waitFor target, condition, options

  # Selection & Refinement (Push)
  select: ( selector ) -> K.push ( target ) -> _.select target, selector
  shadow: K.push ( target ) -> _.shadow target
  
  # Interaction (Peek)
  type: ( text ) -> K.peek ( target ) -> _.type target, text
  click: K.peek ( target ) -> _.click target
  blur: K.peek ( target ) -> _.blur target
  upload: ( ...paths ) -> K.peek ( element ) -> _.upload element, paths
  drag: K.peek ( element ) -> _.drag element
  drop: K.peek ( element ) -> _.drop element
  scroll: ( position ) -> K.peek ( page ) -> _.scroll page, position
  hover: K.peek ( target ) -> _.hover target
  focus: K.peek ( target ) -> _.focus target
  clear: K.peek ( target ) -> _.clear target
  press: ( key ) -> K.peek ( page ) -> _.press page, key
  submit: K.peek ( target ) -> _.submit target

  # Inspection (Push/Peek)
  visible: K.push ( elements ) -> _.visible elements
  accessibility: K.push ( page ) -> _.accessibility page
  content: K.push ( page ) -> _.content page
  text: K.push ( elements ) -> _.text elements
  
  # Data Extraction (Push)
  attribute: ( name ) -> K.push ( target ) -> _.attribute target, name
  evaluate: ( f ) -> K.push ( target ) -> _.evaluate target, f

  # Screenshot (Peek)
  screenshot:
    image: ( options = {} ) -> K.peek ( target ) -> _.screenshot.image target, options
    pdf: ( options = {} ) -> K.peek ( page ) -> _.screenshot.pdf page, options

export default Mimic
