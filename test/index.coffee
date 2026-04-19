import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import lifecycleNavigation from "./cases/lifecycle-navigation"
import emulation from "./cases/emulation"
import interaction from "./cases/interaction"
import inspectionSelection from "./cases/inspection-selection"
import advancedControlState from "./cases/advanced-control-state"

do ->
  print await test "Mimic", [
    lifecycleNavigation()
    emulation()
    interaction()
    inspectionSelection()
    advancedControlState()
  ]

  process.exit if success then 0 else 1
