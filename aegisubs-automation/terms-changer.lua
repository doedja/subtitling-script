script_name = "Terms Changer"
script_description = "Replace terms based on terms.txt in the same folder as subtitle"
script_author = "Doedja"
script_version = "1.0"

function get_file_directory(subtitle_path)
    return subtitle_path:match("(.*[/\\])")
end

function read_terms_file(directory)
    local terms = {}
    local file = io.open(directory .. "terms.txt", "r")
    
    if not file then
        aegisub.log("Could not find terms.txt in: " .. directory)
        return terms
    end
    
    for line in file:lines() do
        if line:match("=>") then
            local source, target = line:match("(.-)%s*=>%s*(.*)")
            if source and target then
                -- Split by comma and trim whitespace
                local sources = {}
                local targets = {}
                
                -- Modified to split only by comma, preserving spaces within terms
                for s in source:gmatch("([^,]+)") do
                    table.insert(sources, s:match("^%s*(.-)%s*$"))
                end
                
                for t in target:gmatch("([^,]+)") do
                    table.insert(targets, t:match("^%s*(.-)%s*$"))
                end
                
                -- Add each source-target pair
                for i = 1, math.min(#sources, #targets) do
                    terms[sources[i]] = targets[i]
                end
            end
        end
    end
    
    file:close()
    return terms
end

function replace_terms(subtitles, selected_lines)
    local directory = aegisub.decode_path("?script") .. "/"
    if not directory then
        aegisub.log("Error: Could not get script directory")
        return
    end
    
    local terms = read_terms_file(directory)
    local total_replacements = 0
    
    for _, i in ipairs(selected_lines) do
        local line = subtitles[i]
        local original_text = line.text
        local modified_text = line.text
        local changes = {}
        
        -- Apply each term replacement
        for source, target in pairs(terms) do
            local new_text, count = modified_text:gsub(source, target)
            if count > 0 then
                -- Store what changed and how many times
                local change_info = string.format("%s→%s", source, target)
                if count > 1 then
                    change_info = change_info .. string.format(" (%dx)", count)
                end
                table.insert(changes, change_info)
                modified_text = new_text
                total_replacements = total_replacements + count
            end
        end
        
        -- Update line if changes were made
        if modified_text ~= original_text then
            line.text = modified_text
            line.effect = table.concat(changes, " | ")
            subtitles[i] = line
        end
    end
    
    aegisub.log(string.format("Total replacements made: %d\n", total_replacements))
end

aegisub.register_macro(script_name, script_description, replace_terms)
