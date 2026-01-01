-- ============================================================================
-- Hammerspoon init.lua
--
-- Purpose:
--   Deterministic application switching via hotkeys.
--
-- Behavior:
--   - If app is running: focus its main window
--   - If not running: launch and focus
--
-- Configuration:
--   - Apps are defined declaratively in ~/.apps.json
--
-- Non-goals:
--   - Window layouts
--   - Spaces management
--   - UI / notifications
-- ============================================================================

local LAUNCH_DELAY = 1.0
local TMUX_CMD_DELAY = 0.3

-- ---------------------------------------------------------------------------
-- Load app configuration
-- ---------------------------------------------------------------------------

local appsFile = hs.configdir .. "/apps.json"
local apps = hs.json.read(appsFile)

if not apps then
  hs.alert.show("Failed to load ~/.apps.json")
  return
end

-- ---------------------------------------------------------------------------
-- Core behavior
-- ---------------------------------------------------------------------------

local function focusOrLaunch(appName, processName)
  local app = hs.application.find(processName)

  -- App not running → launch
  if not app then
    hs.application.launchOrFocus(appName)

    hs.timer.doAfter(LAUNCH_DELAY, function()
      local launched = hs.application.find(processName)
      if launched and launched:mainWindow() then
        launched:mainWindow():focus()
      end
    end)

    return
  end

  -- App running → focus main window
  local window = app:mainWindow()
  if window then
    window:focus()
  else
    hs.application.launchOrFocus(appName)
  end
end

-- ---------------------------------------------------------------------------
-- tmux helper (explicit special case)
-- ---------------------------------------------------------------------------

local function openTmux()
  focusOrLaunch("iTerm", "iTerm2")

  hs.timer.doAfter(TMUX_CMD_DELAY, function()
    hs.eventtap.keyStrokes("tmux attach || tmux new\n")
  end)
end

-- ---------------------------------------------------------------------------
-- Hotkey bindings from apps.json
-- ---------------------------------------------------------------------------

for _, app in pairs(apps) do
  local hotkey = app.hotkey
  if hotkey and #hotkey >= 2 then
    local modifiers = { table.unpack(hotkey, 1, #hotkey - 1) }
    local key = hotkey[#hotkey]

    hs.hotkey.bind(modifiers, key, function()
      focusOrLaunch(app.app, app.process)
    end)
  end
end

-- ---------------------------------------------------------------------------
-- tmux binding
-- ---------------------------------------------------------------------------

hs.hotkey.bind({ "alt" }, "T", openTmux)

-- ---------------------------------------------------------------------------
-- Reload configuration
-- ---------------------------------------------------------------------------

hs.hotkey.bind({ "alt" }, "R", function()
  hs.reload()
  hs.alert.show("Hammerspoon reloaded")
end)
