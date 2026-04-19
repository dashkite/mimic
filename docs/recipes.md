# Mimic Recipes

Common patterns and task-based scenarios for browser automation using Mimic.

## Basic Navigation & Inspection

### Task
Open a page, select a heading, and verify its text content.

### Mimic Approach
Chain lifecycle and DOM interaction combinators.

### Example
```coffeescript
import * as K from "@dashkite/katana"
import Mimic from "@dashkite/mimic"

await do pipe [
  Mimic.browser
  Mimic.page
  Mimic.goto "https://example.com"
  Mimic.select "h1"
  Mimic.text
  K.peek ([ heading ]) -> assert.equal heading, "Example Domain"
]
```

### Algorithm
1.  Initialize the browser session.
2.  Create a new page.
3.  Navigate to the target URL.
4.  Use `select` to find the element.
5.  Use `text` to extract the content.
6.  Assert the result using `K.peek`.

---

## Interacting with Web Components

### Task
Select a custom element, traverse its Shadow DOM, and interact with a nested button.

### Mimic Approach
Use the `shadow` combinator to enter the shadow root.

### Example
```coffeescript
import Mimic from "@dashkite/mimic"

await do pipe [
  Mimic.browser
  Mimic.page
  Mimic.goto "http://localhost:3000"
  Mimic.select "my-custom-element"
  Mimic.shadow
  Mimic.select ".inner-button"
  Mimic.click
]
```

### Algorithm
1.  Navigate to the page containing the custom element.
2.  Select the custom element using its tag name.
3.  Use `shadow` to push the shadow root onto the stack.
4.  Perform subsequent selections and interactions within that shadow root.

---

## Form Submission Flow

### Task
Complete a registration form by filling out multiple fields and submitting.

### Mimic Approach
Sequence `select`, `type`, and `submit` operations.

### Example
```coffeescript
import Mimic from "@dashkite/mimic"

await do pipe [
  Mimic.browser
  Mimic.page
  Mimic.goto "/register"
  Mimic.select "input[name='email']"
  Mimic.type "alice@example.com"
  Mimic.select "input[name='nickname']"
  Mimic.type "alice"
  Mimic.select "form"
  Mimic.submit
  Mimic.wait()
]
```

### Algorithm
1.  Navigate to the form page.
2.  For each field:
    - Select the input.
    - Type the value.
3.  Select the form element.
4.  Use `submit` to trigger the submission.
5.  Use `wait()` to ensure the next page or state is reached.
