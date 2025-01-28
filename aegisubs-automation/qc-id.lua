script_name = "Indonesian QC"
script_description = "Quality check for Indonesian subtitles"
script_author = "Doedja"
script_version = "1.0"

-- Groups of words to check
local word_pairs = {
    contradictions = {
        {"meski", {"tapi", "tetapi"}},
        {"walau", {"tapi", "tetapi"}},
    },
    conditionals = {
        {"kalau", {"maka"}},
        {"karena", {"jadi"}},
    }
}

local informal_words = {
    ["di mana"] = "gunakan 'tempat/yang'",
    ["bagaimana pun"] = "'bagaimanapun'",
    ["pamungkas"] = "'pemungkas'",
    ["takkan"] = "'tidak akan'",
    ["memerhatikan"] = "'memperhatikan'",
    ["memberitahu"] = "'memberi tahu'",
}

local punctuation_checks = {
    ["%-%-"] = "Gunakan tanda emdash (—)",
    ["–"] = "Gunakan tanda emdash (—)",
    ["…"] = "Gunakan tiga titik (...)",
    ["%.%.%."] = "Spasi sebelum & sesudah tiga titik",
    ["[%S]!%S"] = "Spasi setelah tanda seru",
    ["[%S]%?%S"] = "Spasi setelah tanda tanya",
    ["%s+!"] = "Jangan spasi sebelum tanda seru",
    ["%s+%?"] = "Jangan spasi sebelum tanda tanya",
    [",%S"] = "Spasi setelah koma",
    ["%s+,"] = "Jangan spasi sebelum koma",
    ["%s+%."] = "Jangan spasi sebelum titik",
    ["%.%S"] = "Spasi setelah titik",
    ["%s%s+"] = "Spasi ganda",
    -- New patterns for quotation marks
    [',["%"]'] = 'Tanda koma harus setelah tanda kutip (")',
    ['%.["%"]'] = 'Tanda titik harus setelah tanda kutip (")',
    ['["%"]%.%s+[%u]'] = 'Tanda titik harus sebelum tanda kutip (")',
    ['["%"],%s+[%u]'] = 'Tanda koma harus sebelum tanda kutip (")',
}

-- Check if any word from the list exists in the text
local function contains_word(text, word_list)
    if type(word_list) == "string" then
        return text:lower():find(word_list:lower()) ~= nil
    end
    
    for _, word in ipairs(word_list) do
        if text:lower():find(word:lower()) then
            return true
        end
    end
    return false
end

-- Helper function to check if text starts with capital letter
local function starts_with_capital(text)
    local first_char = text:match("^%s*(.)")
    return first_char and first_char:match("%u")
end

-- Get combined text for continuous lines
local function get_combined_text(subtitles, current_index)
    local combined_text = subtitles[current_index].text
    local prev_index = current_index - 1
    
    -- Check previous lines if current line doesn't start with capital
    if not starts_with_capital(combined_text) then
        while prev_index > 0 do
            local prev_line = subtitles[prev_index]
            if prev_line.class ~= "dialogue" then break end
            
            -- Combine with previous line
            combined_text = prev_line.text .. " " .. combined_text
            
            -- Stop if previous line starts with capital
            if starts_with_capital(prev_line.text) then break end
            prev_index = prev_index - 1
        end
    end
    
    return combined_text
end

-- Main processing function
function check_line(subtitles, line, line_index)
    local issues = {}
    -- Get combined text for checking
    local combined_text = get_combined_text(subtitles, line_index)
    local text = combined_text:lower()
    
    -- Check word pairs
    for group_name, pairs in pairs(word_pairs) do
        for _, pair in ipairs(pairs) do
            local first_word, second_words = pair[1], pair[2]
            if contains_word(text, first_word) and contains_word(text, second_words) then
                table.insert(issues, string.format("%s+%s", 
                    first_word, table.concat(second_words, "/")))
            end
        end
    end
    
    -- Check informal or incorrect words
    for word, message in pairs(informal_words) do
        if text:find(word:lower()) then
            table.insert(issues, string.format("%s→%s", word, message))
        end
    end

    -- Check punctuation (using original text to preserve case)
    for pattern, message in pairs(punctuation_checks) do
        if line.text:find(pattern) then
            table.insert(issues, message)
        end
    end
    
    return issues
end

function process_subs(subtitles, selected_lines, active_line)
    local issues_found = false
    
    for i = 1, #subtitles do
        local line = subtitles[i]
        if line.class == "dialogue" then
            local issues = check_line(subtitles, line, i)  -- Pass line index
            
            if #issues > 0 then
                issues_found = true
                local effect = table.concat(issues, " | ")
                line.effect = effect
                subtitles[i] = line
            end
        end
    end
    
    if issues_found then
        aegisub.dialog.display({{class="label", 
            label="QC selesai. Silakan cek kolom Effect untuk melihat masalah yang ditemukan."}}, 
            {"OK"})
    else
        aegisub.dialog.display({{class="label", 
            label="QC selesai. Tidak ditemukan masalah."}}, 
            {"OK"})
    end
    
    aegisub.set_undo_point("Indonesian QC")
end

aegisub.register_macro(script_name, script_description, process_subs) 