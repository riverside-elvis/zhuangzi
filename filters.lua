function do_strings (elem)
    local text = elem.text
    -- Replace characters with no font glyphs.
    if string.find(text, "𤴯") then
        text = text:gsub("𤴯", "⿸")
    end
    return pandoc.Str(text)
end

return {{Str = do_strings}}
