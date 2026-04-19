import Generic from "@dashkite/generic"
import { Page, BrowserContext, Browser } from "puppeteer"

export close = Generic.make
  name: "Mimic.close"
  default: ( target ) ->
    throw new Error "close: expected Page, BrowserContext, or Browser,
      but received [ #{ target?.constructor?.name ? typeof target } ]."

close.define [ Page ], ( page ) -> page.close()
close.define [ BrowserContext ], ( context ) -> context.close()
close.define [ Browser ], ( browser ) -> browser.close()
