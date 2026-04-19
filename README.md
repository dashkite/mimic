# Mimic

*Katana combinators for running headless browser tests with Puppeteer.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Mimic provides a set of stack-based combinators, powered by Katana, for orchestrating browser interactions using Puppeteer. It enables clear, declarative browser automation and testing by treating the browser session as a composable flow of operations.

```coffeescript
import { pipe } from "@dashkite/joy/function"
import Mimic from "@dashkite/mimic"

await pipe [
  Mimic.browser()
  Mimic.context
  Mimic.page
  Mimic.goto "https://example.com"
  Mimic.select "h1"
  Mimic.text
  ([ texts ]) -> assert.equal texts[0], "Example Domain"
]
```

### Features
- **Stack-Based Composition**: Leverage Katana to build readable browser interaction pipelines.
- **Web Component Support**: Built-in support for Shadow DOM traversal and waiting for custom element definitions.
- **Declarative API**: Unified interface for navigation, selection, inspection, and interaction.
- **Puppeteer Powered**: Reliability and performance of the industry-standard headless browser library.

## Installation

Install via your favorite package manager:

```bash
pnpm add @dashkite/mimic
```

## Usage

Mimic combinators are asynchronous and designed to be used within a Katana-compatible pipeline. They typically operate on a stack containing browser instances, contexts, pages, and element handles.

```coffeescript
import Mimic from "@dashkite/mimic"

# Example: Submitting a login form
await pipe [
  Mimic.browser()
  Mimic.page
  Mimic.goto "/login"
  Mimic.select "input[name='username']"
  Mimic.type "alice"
  Mimic.select "form"
  Mimic.submit
]

# Example: Emulating a device
await pipe [
  Mimic.browser()
  Mimic.page
  Mimic.emulate "iphone/15"
  Mimic.goto "https://example.com"
  Mimic.screenshot.image path: "iphone-example.png"
]
```

## Other Resources
- [Reference](./docs/reference.md): Detailed API documentation for all combinators.
- [Recipes](./docs/recipes.md): Task-based scenarios for common browser automation patterns.

## Status
This software is currently in active development and is not yet suitable for production use. Please report bugs or request features via the repository's issue tracker.
