# Aegisub Automation Scripts

A personal collection of Lua scripts for Aegisub to help with subtitle editing.

## Installation

Copy the `.lua` files to your Aegisub automation folder:
- Windows: `%AppData%\Aegisub\automation\autoload`
- Linux: `~/.aegisub/automation/autoload`
- MacOS: `~/Library/Application Support/Aegisub/automation/autoload`

## Scripts

### Indonesian QC (qc-id.lua)
Quality checker for Indonesian subtitles. Checks for:
- Common word pair mistakes (meski + tapi, etc.)
- Informal words
- Punctuation rules

Usage: Automation > Indonesian QC. Results appear in the Effect column.

### Screen Text Capitalizer (screen-text.lua)
Converts text in parentheses to uppercase and removes the parentheses.
- "(text on screen)" → "TEXT ON SCREEN"

Usage: Select lines > Automation > Screen Text Capitalizer

### Subtitle Folder Search (searcher.lua)
Search for text across multiple subtitle files in the current folder.
- Searches both .srt and .ass files
- Shows results grouped by episode
- Case insensitive search

Usage: Automation > Subtitle Folder Search

### Terms Changer (terms-changer.lua)
Replace terms based on terms.txt in the same folder as subtitle (case sensitive).
- terms.txt format:
  old-word1 => new-word1
  old-word2, old-word3 => new-word2, new-word3
  ...

Usage: Select lines > Automation > Terms Changer
