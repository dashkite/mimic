# Mimic Reference

Detailed API documentation for Mimic combinators. All combinators are asynchronous and return promises.

## Lifecycle & Navigation

#### browser
$browser: \dashrightarrow [ browser ]$

Launches a Puppeteer browser instance using default options and returns it in an array (initial stack).

#### browser.with
$browser.with: options \dashrightarrow combinator$

Returns a combinator that, when called, launches a Puppeteer browser instance with the given `options`.

#### context
$context: \dashrightarrow context$

Creates a new browser context and pushes it onto the stack. Expects a `browser` at the top of the stack.

#### page
$page: \dashrightarrow page$

Creates a new page within the current context and pushes it onto the stack. Expects a `context` at the top of the stack.

#### close
$close: \dashrightarrow \varnothing$

Closes the current target (Page, BrowserContext, or Browser). Expects a `page`, `context`, or `browser` at the top of the stack.

#### agent
$agent: name \dashrightarrow \varnothing$

Sets the user agent for the current page. Expects a `page` at the top of the stack.
- `name`: A user agent string or a shorthand (e.g., `agent/mac/webkit`).

#### console
$console: handler \dashrightarrow \varnothing$

Registers a `handler` for browser `console` events. Expects a `page` at the top of the stack.

#### error
$error: handler \dashrightarrow \varnothing$

Registers a `handler` for browser `pageerror` events. Expects a `page` at the top of the stack.

#### mock
$mock: pattern, handler \dashrightarrow \varnothing$

Intercepts network requests matching `pattern` (string or regex) and calls `handler`. Expects a `page` at the top of the stack.

#### goto
$goto: url \dashrightarrow \varnothing$

Navigates the current page to the specified URL. Expects a `page` at the top of the stack.

#### reload
$reload: \dashrightarrow \varnothing$

Reloads the current page.

#### back
$back: \dashrightarrow \varnothing$

Navigates to the previous page in history.

#### forward
$forward: \dashrightarrow \varnothing$

Navigates to the next page in history.

#### wait
$wait: options \dashrightarrow \varnothing$

Waits for the current page to reach a network idle state.
- `options.idleTime`: Duration of network idle time to wait for (default: 500ms).
- `options.timeout`: Maximum time to wait (default: 10000ms).

#### waitFor
$waitFor: condition, options \dashrightarrow \varnothing$

Waits for a specific condition.
- If `condition` is a string, it waits for the selector to appear.
- If `condition` is a function, it evaluates it in the browser context until it returns truthy.
- `options.timeout`: Maximum time to wait (default: 10000ms).

## Emulation

#### viewport
$viewport: options \dashrightarrow \varnothing$

Sets the page's screen size and other viewport properties.
- `options`: A viewport object or a shorthand (e.g., `view/mac`).

#### emulate
$emulate: device \dashrightarrow \varnothing$

Emulates a specific device (viewport and user agent).
- `device`: A device object or a shorthand (e.g., `iphone/15`).

#### media
$media: type, features \dashrightarrow \varnothing$

Emulates a media type (e.g., `print`) or features (e.g., `prefers-color-scheme`).

## Clock

#### clock.tick
$clock.tick: ms \dashrightarrow \varnothing$

Fast-forwards the browser's virtual time by the specified number of milliseconds.

## Storage

#### storage.clear
$storage.clear: \dashrightarrow \varnothing$

Clears `localStorage` and `sessionStorage` for the current page.

## Dialog

#### dialog.accept
$dialog.accept: \dashrightarrow \varnothing$

Registers a listener to automatically accept the next browser dialog.

#### dialog.dismiss
$dialog.dismiss: \dashrightarrow \varnothing$

Registers a listener to automatically dismiss the next browser dialog.

## Cookies

#### cookies.get
$cookies.get: \dashrightarrow cookies$

Pushes the cookies for the current page or context onto the stack.

#### cookies.set
$cookies.set: cookies \dashrightarrow \varnothing$

Sets cookies for the current page or context.

## Inspection & Debugging

#### content
$content: \dashrightarrow html$

Pushes the HTML content of the current page onto the stack.

#### text
$text: \dashrightarrow values$

Pushes an array of `textContent` values for the current collection of nodes onto the stack.

#### attribute
$attribute: name \dashrightarrow value$

Pushes the value of the specified attribute for the **first** node in the collection onto the stack.

#### visible
$visible: \dashrightarrow nodes$

Filters the current collection of nodes, keeping only those that are visible.

#### accessibility
$accessibility: \dashrightarrow snapshot$

Pushes a snapshot of the current accessibility tree.

#### screenshot.image
$screenshot.image: options \dashrightarrow \varnothing$

Takes a screenshot of the current page or element.

#### screenshot.pdf
$screenshot.pdf: options \dashrightarrow \varnothing$

Generates a PDF of the current page.

#### pause
$pause: \dashrightarrow \varnothing$

Sleeps for 100 milliseconds.

#### sleep
$sleep: ms \dashrightarrow \varnothing$

Sleeps for the specified duration.

## Reporting

#### report.console
$report.console: message \dashrightarrow \varnothing$

A visually rich formatter for browser `console` events. It parses CDP `%c` formatting, applies color coding based on message type (log, warning, error), and prefixes output with a color-coded `[ browser ]` prompt. Designed to be used with the `console` combinator.

#### report.error
$report.error: error \dashrightarrow \varnothing$

A visually rich formatter for browser `pageerror` events. It styles the error message in red and prefixes it with a red `[ browser ]` prompt. Designed to be used with the `error` combinator.

## DOM Interaction

#### select
$select: selector \dashrightarrow nodes$

Selects nodes matching the CSS selector and pushes the resulting array of element handles onto the stack.

#### shadow
$shadow: \dashrightarrow root$

Pushes the `shadowRoot` for the **first** node in the current collection onto the stack.

#### evaluate
$evaluate: f \dashrightarrow result$

Evaluates the given function in the browser context, passing the current node collection as an argument. Pushes the result onto the stack.

#### scroll
$scroll: position \dashrightarrow \varnothing$

Scrolls the page. Currently supports:
- `bottom`: Scrolls to the end of the document.

#### click
$click: \dashrightarrow \varnothing$

Simulates a click on the **first** node in the current collection.

#### blur
$blur: \dashrightarrow \varnothing$

Removes focus from the **first** node in the current collection.

#### type
$type: text \dashrightarrow \varnothing$

Simulates typing the specified text into the **first** node in the current collection.

#### upload
$upload: ...paths \dashrightarrow \varnothing$

Uploads files to the **first** node in the current collection (expects a file input).

#### drag
$drag: \dashrightarrow \varnothing$

Simulates a mouse down event on the **first** node in the current collection and moves the mouse to its center.

#### drop
$drop: \dashrightarrow \varnothing$

Simulates moving the mouse to the center of the **first** node in the current collection and a mouse up event.
