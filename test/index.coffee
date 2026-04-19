import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import { once } from "@dashkite/joy/function"
import Mimic from "@dashkite/mimic"

import lifecycleNavigation from "./cases/lifecycle-navigation"
import emulation from "./cases/emulation"
import interaction from "./cases/interaction"
import inspectionSelection from "./cases/inspection-selection"
import advancedControlState from "./cases/advanced-control-state"

do ->
  start = once Mimic.browser
  try
    print await test "Mimic", [
      lifecycleNavigation start
      emulation start
      interaction start
      inspectionSelection start
      advancedControlState start
    ]
  finally
    [ browser ] = await start()
    await browser.close()

  process.exit if success then 0 else 1
