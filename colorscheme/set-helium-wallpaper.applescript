on run argv
  set wallpaperPath to item 1 of argv
  set previousProcessName to ""
  set targetWindowId to ""
  set originalFrontWindowId to ""
  set originalActiveIndex to 1
  set temporaryTab to missing value

  try
    tell application "System Events"
      set previousProcessName to name of first application process whose frontmost is true
    end tell

    tell application "Helium"
      set originalFrontWindowId to id of front window

      repeat with browserWindow in every window
        repeat with browserTab in every tab of browserWindow
          set tabURL to URL of browserTab
          if (tabURL starts with "chrome://newtab") or (tabURL starts with "chrome://new-tab-page") or (tabURL is "about:newtab") then
            set targetWindowId to id of browserWindow
            exit repeat
          end if
        end repeat
        if targetWindowId is not "" then exit repeat
      end repeat

      if targetWindowId is "" then error "Helium has no new-tab window available for native wallpaper selection."

      set targetWindow to window id targetWindowId
      set originalActiveIndex to active tab index of targetWindow
      set temporaryTab to make new tab at end of tabs of targetWindow with properties {URL:"chrome://customize-chrome-side-panel.top-chrome/"}
      set active tab index of targetWindow to count of tabs of targetWindow
      activate
    end tell

    repeat 100 times
      tell application "Helium" to set pageLoading to loading of temporaryTab
      if not pageLoading then exit repeat
      delay 0.1
    end repeat
    delay 0.5

    tell application "Helium"
      set clickResult to execute temporaryTab javascript "(() => { let target; const walk = node => { if (node.id === 'uploadImageTile') target = node; if (node.shadowRoot) walk(node.shadowRoot); for (const child of node.children || []) walk(child); }; walk(document); if (!target) return 'missing'; target.click(); return 'clicked'; })()"
    end tell
    if clickResult is not "clicked" then error "Helium's native wallpaper action was not available."

    tell application "System Events"
      tell process "Helium"
        repeat 50 times
          if (count of sheets of front window) > 0 then exit repeat
          delay 0.1
        end repeat
      end tell

      keystroke "g" using {command down, shift down}
      delay 0.3
      keystroke "a" using {command down}
      keystroke wallpaperPath
      key code 36

      tell process "Helium"
        tell sheet 1 of front window
          set openReady to false
          repeat 100 times
            if enabled of button "Open" then
              set openReady to true
              exit repeat
            end if
            delay 0.1
          end repeat
          if not openReady then error "The selected wallpaper format was not accepted by Helium."
          click button "Open"
        end tell

        repeat 100 times
          if (count of sheets of front window) is 0 then exit repeat
          delay 0.1
        end repeat
      end tell
    end tell

    delay 0.5
    tell application "Helium"
      close temporaryTab
      set active tab index of window id targetWindowId to originalActiveIndex
      if originalFrontWindowId is not "" then set index of window id originalFrontWindowId to 1
    end tell

    if previousProcessName is not "Helium" then
      tell application "System Events" to set frontmost of process previousProcessName to true
    end if
  on error errorMessage
    try
      tell application "Helium"
        if temporaryTab is not missing value then close temporaryTab
        if targetWindowId is not "" then set active tab index of window id targetWindowId to originalActiveIndex
        if originalFrontWindowId is not "" then set index of window id originalFrontWindowId to 1
      end tell
    end try
    try
      if previousProcessName is not "" and previousProcessName is not "Helium" then
        tell application "System Events" to set frontmost of process previousProcessName to true
      end if
    end try
    error errorMessage
  end try
end run
