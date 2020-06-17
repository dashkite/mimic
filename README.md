# Mimic

Katana combinators for running headless browser tests with Puppeteer.

```coffeescript
flow [
  wrap [ puppeteer.launch() ]
  page "http://localhost:3000"
  tee flow [
    defined "x-register"
    select "x-register"
    shadow
    select "input[name='nickname']"
    type faker.internet.userName()
    select "form"
    submit
  ]
  defined "x-messages"
  select "x-messages"
  poke $.shadow
  poke $.select ".container"
  waitFor (container) ->
    if container.textContent.trim() != ""
      container.textContent
  equal "Registration succeeded"
]
```

# Installation

Bundle using your favorite bundler:

```
npm i @dashkite/mimic
```

# API

## `page url`

Navigate to the given URL. Places the resulting page on the stack.

## `defined name`

Wait until the custom element corresponding to the given name is defined.

## `render html`

Set the `innerHTML` of the element at the top of the stack to given HTML.

## `select selector`

Selects and pushes an element matching the given selector.

## `shadow`

Pushes the `shadowRoot` for the node at the top of the stack.

## `sleep ms`

Sleep for the given duration in milliseconds.

## `pause`

Sleep for 1 second.

## `clear`

Clears the `value` of the element at the top of the stack.

## `type text`

Simulates typing the given text into the form element at the top of the stack.

## `submit`

Calls `requestSubmit` on the form element at the top of the stack.

## `evaluate fn`

Given a page at the top of the stack, evaluates the given function in browser context. The function may take the node as an argument.

## `waitFor condition`

Given a page at the top of the stack, evaluates the given function in browser context until it returns a truthy value. The function may take the node as an argument. Any return value is automatically serialized and pushed onto the stack.

## `equal expected`

Given a value at the top of the stack, calls `assert.equal` with the given and expected values.
