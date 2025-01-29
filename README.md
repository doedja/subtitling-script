# Aegisub Automation Scripts

A personal collection of Lua scripts for Aegisub to help with subtitle editing.

## Installation

Copy the `.lua` files to your Aegisub automation folder:
   - Windows: `%AppData%\Aegisub\automation\`
   - Linux: `~/.aegisub/automation/`
   - MacOS: `~/Library/Application Support/Aegisub/automation/`

## Scripts

### Indonesian QC (qc-id.lua)
Quality checker for Indonesian subtitles. Checks for:
- Common word pair mistakes (meski + tapi, etc.)
- Informal words
- Punctuation rules

Usage: Automation > Indonesian QC. Results appear in the Effect column.

### Screen Text Capitalizer (screen-text.lua)
Converts text in parentheses to uppercase and removes the parentheses.

Example: "(text on screen)" → "TEXT ON SCREEN"

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
  - source1 => target1
  - source2, Source3 => target2, target3
  - ...

Usage: Select lines > Automation > Terms Changer
