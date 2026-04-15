# Mimic Reference

Detailed API documentation for Mimic combinators. All combinators are asynchronous and return promises.

## Lifecycle & Navigation

#### start
$start: browser \dashrightarrow stack$

Initiates a Mimic flow by wrapping a Puppeteer `browser` instance and placing it on the stack.

#### context
$context: \dashrightarrow context$

Creates a new browser context and pushes it onto the stack. Expects a `browser` at the top of the stack.

#### page
$page: \dashrightarrow page$

Creates a new page within the current context and pushes it onto the stack. Expects a `context` at the top of the stack.

#### agent
$agent: name \dashrightarrow \varnothing$

Sets the user agent for the current page. Expects a `page` at the top of the stack.

#### goto
$goto: url \dashrightarrow \varnothing$

Navigates the current page to the specified URL. Expects a `page` at the top of the stack.

#### wait
$wait: \dashrightarrow \varnothing$

Waits for the current page to reach a network idle state.

#### waitFor
$waitFor: condition, options \dashrightarrow \varnothing$

Waits for a specific condition.
- If `condition` is a string, it waits for the selector to appear.
- If `condition` is a function, it evaluates it in the browser context until it returns truthy.

## Inspection & Debugging

#### content
$content: \dashrightarrow html$

Pushes the HTML content of the current page onto the stack.

#### count
$count: \dashrightarrow number$

Pushes the number of elements in the current collection onto the stack. Expects an array of element handles at the top of the stack.

#### text
$text: \dashrightarrow values$

Pushes an array of `textContent` values for the current collection of nodes onto the stack.

#### attribute
$attribute: name \dashrightarrow value$

Pushes the value of the specified attribute for the **first** node in the collection onto the stack.

#### screenshot
$screenshot: path \dashrightarrow \varnothing$

Takes a screenshot of the current page and saves it to the specified path.

#### pause
$pause: \dashrightarrow \varnothing$

Sleeps for 100 milliseconds.

#### sleep
$sleep: ms \dashrightarrow \varnothing$

Sleeps for the specified duration.

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

#### hover
$hover: \dashrightarrow \varnothing$

Simulates moving the mouse over the **first** node in the current collection.

#### focus
$focus: \dashrightarrow \varnothing$

Focuses the **first** node in the current collection.

#### clear
$clear: \dashrightarrow \varnothing$

Clears the `value` of the **first** node in the current collection.

#### type
$type: text \dashrightarrow \varnothing$

Simulates typing the specified text into the **first** node in the current collection.

#### press
$press: key \dashrightarrow \varnothing$

Simulates a single key press (e.g., "Enter", "Tab").

#### submit
$submit: \dashrightarrow \varnothing$

Triggers a form submission for the **first** node in the current collection. Attempts `requestSubmit`, then finding a submit button, and finally `submit()`.
