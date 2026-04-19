import { isKind } from "@dashkite/joy/type"
import { Page, JSHandle } from "puppeteer"

export isPage = isKind Page
export isTarget = ( x ) -> ( isKind Page, x ) || ( isKind JSHandle, x )
