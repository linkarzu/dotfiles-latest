on adding folder items to this_folder after receiving added_items
  if (count of added_items) is 0 then return

  set p to POSIX path of (item 1 of added_items)
  -- IMPORTANT:
  -- quoted form of p is for the shell, not for AppleScript syntax.
  -- We must pass Finder a proper AppleScript string: POSIX file "..."
  set safePath to my escapeForAppleScriptString(p)
  set osaCmd to "tell application \"Finder\" to set the clipboard to (POSIX file \"" & safePath & "\")"
  do shell script "osascript -e " & quoted form of osaCmd
end adding folder items to

on escapeForAppleScriptString(s)
  set s2 to my replaceText(s, "\\", "\\\\")
  set s3 to my replaceText(s2, "\"", "\\\"")
  return s3
end escapeForAppleScriptString

on replaceText(theText, findText, replaceWith)
  set AppleScript's text item delimiters to findText
  set parts to text items of theText
  set AppleScript's text item delimiters to replaceWith
  set outText to parts as text
  set AppleScript's text item delimiters to ""
  return outText
end replaceText
