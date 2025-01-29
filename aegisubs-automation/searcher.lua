script_name = "Subtitle Folder Search"
script_description = "Search for text across multiple subtitle files in the current folder"
script_author = "Doedja"
script_version = "1.0"

-- Import the required modules
local lfs = require "lfs"

-- Function to read file content
local function read_file(filepath)
    local file = io.open(filepath, "r", "utf-8")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

-- Main processing function
function search_subtitles(subtitles, selected_lines, active_line)
    -- Get the directory of the current subtitle file
    local dir = aegisub.decode_path("?script") .. "/"
    
    -- Get a list of .srt and .ass files in the same directory
    local files = {}
    for file in lfs.dir(dir) do
        if file:match("%.srt$") or file:match("%.ass$") then
            table.insert(files, file)
        end
    end
    
    if #files == 0 then
        aegisub.debug.out("No .srt or .ass files found in the current directory.\n")
        return
    end

    -- Keep searching until user cancels
    local last_results = "" -- Store previous results
    while true do
        -- Prompt the user for the search term
        local dialog_config = {
            {class="label", label="Enter a word or sentence to search for (case insensitive):", x=0, y=0},
            {class="edit", name="search_term", x=0, y=1, width=40},
            {class="textbox", name="results", text=last_results, x=0, y=2, width=40, height=15},
        }
        local btn, res = aegisub.dialog.display(dialog_config, {"Search", "Close"})
        if btn ~= "Search" then break end
        
        local search_term = res.search_term:lower()
        if search_term == "" then
            last_results = "\nPlease enter a search term.\n"
        else
            -- Search in all subtitle files
            local results = {}
            for _, file in ipairs(files) do
                local content = read_file(dir .. file)
                if content and content:lower():find(search_term) then
                    if not results[file] then results[file] = {} end
                    -- Find all lines containing the search term
                    for line in content:gmatch("[^\r\n]+") do
                        -- Match whole words only using word boundaries
                        if line:lower():match("%f[%a]" .. search_term .. "%f[^%a]") then
                            table.insert(results[file], line:match("^%s*(.-)%s*$"))
                        end
                    end
                end
            end

            -- Build results string
            local result_text = string.format("\n=== Search Results for '%s' ===\n\n", search_term)
            if next(results) then
                for file, lines in pairs(results) do
                    local ep_num = file:match("EP(%d+)")
                    local header = ep_num and string.format("Episode %s", ep_num) or file
                    
                    result_text = result_text .. string.format("▶ %s\n", header)
                    result_text = result_text .. string.format("  File: %s\n", file)
                    result_text = result_text .. string.format("  Lines found: %d\n", #lines)
                    result_text = result_text .. "  ───────────────────\n"
                    
                    for _, line in ipairs(lines) do
                        result_text = result_text .. string.format("  • %s\n", line)
                    end
                    result_text = result_text .. "\n"
                end
            else
                result_text = result_text .. "No matches found.\n"
            end
            result_text = result_text .. "=== End of Results ===\n"
            last_results = result_text
        end
    end
end

aegisub.register_macro(script_name, script_description, search_subtitles)
