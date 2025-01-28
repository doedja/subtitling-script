script_name = "Screen Text Capitalizer"
script_description = "Capitalizes text inside parentheses and removes the parentheses"
script_author = "Doedja"
script_version = "1.0"

function capitalize_and_reformat(subs, sel)
    for _, i in ipairs(sel) do
        local line = subs[i]
        local text = line.text
        
        -- Process parentheses
        text = text:gsub("%b()", function(s)
            return string.upper(s:sub(2, -2))  -- Remove parentheses and uppercase
        end)
        
        line.text = text
        subs[i] = line
    end
    aegisub.set_undo_point("Screen Text Modified")
end

aegisub.register_macro(script_name, script_description, capitalize_and_reformat)
