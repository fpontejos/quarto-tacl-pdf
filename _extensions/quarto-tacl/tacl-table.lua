local function join(lst, sep)
    if #lst == 0 then
        return ""
    end
    local result = lst[1]
    for i = 2, #lst do
        result = result .. sep .. lst[i]
    end
    return result
end

function Table(tbl)

    local caption_text = pandoc.write(pandoc.Pandoc{ table.unpack(tbl.caption.long) }, "latex")
    
    -- Build column specification from colspecs
    local colspec = {}
    for _, spec in ipairs(tbl.colspecs) do
        local align = spec[1]  -- Alignment value
        if align == "AlignLeft" then
            table.insert(colspec, "l")
        elseif align == "AlignRight" then
            table.insert(colspec, "r")
        elseif align == "AlignCenter" then
            table.insert(colspec, "c")
        else
            table.insert(colspec, "l")  -- Default to left
        end
    end
    local colspec_str = table.concat(colspec, "")



    -- Start building LaTeX code
    local latex = {}
    table.insert(latex, "\\begin{table}[ht]")
    table.insert(latex, "\\begin{center}")
    table.insert(latex, "\\begin{tabular}{" .. colspec_str .. "}")
    table.insert(latex, "\\hline")

    local header = {}
    for _, h in ipairs(tbl.head.rows[1].cells) do
        table.insert(header, pandoc.write(pandoc.Pandoc{ table.unpack(h.content) }, "latex"))
    end
    
    local body = {}
    for _, row in ipairs(tbl.bodies[1].body) do
        local row_items = {}
        for _, i in ipairs(row.cells) do
            table.insert(row_items, pandoc.write(pandoc.Pandoc{ table.unpack(i.content) }, "latex"))
        end
        table.insert(body, join(row_items, " & ") .. "\\\\")
    end

    table.insert(latex, join(header, " & ") .. "\\\\\n")
    table.insert(latex, "\\hline")
    table.insert(latex, join(body, "\n") .. "\n")

    -- End tabular
    table.insert(latex, "\\hline")
    table.insert(latex, "\\end{tabular}")
    table.insert(latex, "\\end{center}")

    -- Add caption with label in the desired format
    if caption_text ~= "" then
        table.insert(latex, "\\caption{" .. caption_text .. "}")

    end

    table.insert(latex, "\\end{table}")


    local raw_block = pandoc.RawBlock('latex', table.concat(latex, "\n"))
    
    return raw_block

end

