local M = {}

local supported_filetypes = {
    c = true,
    cpp = true,
}

local function is_supported_buffer(bufnr)
    return vim.bo[bufnr].buftype == "" and supported_filetypes[vim.bo[bufnr].filetype] == true
end

local function style_file()
    return vim.fs.normalize(vim.fn.expand("~/.clang-format"))
end

local function clone_lines(lines)
    return vim.list_extend({}, lines)
end

local function read_saved_lines(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return nil
    end

    local stat = vim.uv.fs_stat(filename)
    if not stat or stat.type ~= "file" then
        return nil
    end

    local ok, lines = pcall(vim.fn.readfile, filename)
    if not ok then
        return nil
    end

    return lines
end

local function diff_indices(original_lines, current_lines)
    local before = clone_lines(original_lines)
    local after = clone_lines(current_lines)

    table.insert(before, "")
    table.insert(after, "")

    return vim.diff(table.concat(before, "\n"), table.concat(after, "\n"), {
        algorithm = "histogram",
        result_type = "indices",
    }) or {}
end

local function range_from_index(index, line_count)
    local _, _, new_start, new_count = unpack(index)

    if line_count <= 0 then
        return nil
    end

    if new_count == 0 then
        local start_line = math.max(math.min(new_start - 1, line_count), 1)
        local end_line = math.max(math.min(new_start, line_count), start_line)
        return { start = start_line, ["end"] = end_line }
    end

    local start_line = math.max(math.min(new_start, line_count), 1)
    local end_line = math.max(math.min(new_start + new_count - 1, line_count), start_line)
    return { start = start_line, ["end"] = end_line }
end

local function merge_ranges(ranges)
    if #ranges < 2 then
        return ranges
    end

    table.sort(ranges, function(left, right)
        return left.start < right.start
    end)

    local merged = { ranges[1] }
    for i = 2, #ranges do
        local current = ranges[i]
        local last = merged[#merged]

        if current.start <= (last["end"] + 1) then
            last["end"] = math.max(last["end"], current["end"])
        else
            merged[#merged + 1] = current
        end
    end

    return merged
end

local function changed_ranges(bufnr)
    local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local saved_lines = read_saved_lines(bufnr)

    if not saved_lines then
        return {
            { start = 1, ["end"] = math.max(line_count, 1) },
        }
    end

    local ranges = {}
    for _, index in ipairs(diff_indices(saved_lines, current_lines)) do
        local range = range_from_index(index, line_count)
        if range then
            ranges[#ranges + 1] = range
        end
    end

    return merge_ranges(ranges)
end

local function conform_range(bufnr, range)
    local end_line = vim.api.nvim_buf_get_lines(bufnr, range["end"] - 1, range["end"], false)[1] or ""

    return {
        start = { range.start, 0 },
        ["end"] = { range["end"], #end_line },
    }
end

function M.clang_format_prepend_args()
    return {
        "--style=file:" .. style_file(),
        "--fallback-style=none",
    }
end

function M.sources(bufnr)
    if not is_supported_buffer(bufnr) then
        return {}
    end

    local info = require("conform").get_formatter_info("clang-format", bufnr)
    if not info.available then
        return {}
    end

    return { "clang-format (~/.clang-format, changed ranges)" }
end

function M.format(bufnr)
    if not is_supported_buffer(bufnr) then
        return
    end

    local conform = require("conform")
    local info = conform.get_formatter_info("clang-format", bufnr)
    if not info.available then
        return
    end

    local ranges = changed_ranges(bufnr)
    for i = #ranges, 1, -1 do
        conform.format({
            async = false,
            bufnr = bufnr,
            formatters = { "clang-format" },
            lsp_format = "never",
            quiet = false,
            range = conform_range(bufnr, ranges[i]),
            timeout_ms = 3000,
            undojoin = true,
        })
    end
end

return M
