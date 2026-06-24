return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    config = function()
        local ok, TS = pcall(require, "nvim-treesitter-textobjects")
        if not ok or not TS.setup then
            return
        end

        TS.setup({
            select = {
                lookahead = true,

                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "V",
                },

                include_surrounding_whitespace = false,
            },

            move = {
                set_jumps = true,
            },
        })

        local select = require("nvim-treesitter-textobjects.select")

        for _, mode in ipairs({ "x", "o" }) do
            vim.keymap.set(mode, "af", function()
                select.select_textobject("@function.outer", "textobjects")
            end)

            vim.keymap.set(mode, "if", function()
                select.select_textobject("@function.inner", "textobjects")
            end)

            vim.keymap.set(mode, "ac", function()
                select.select_textobject("@class.outer", "textobjects")
            end)

            vim.keymap.set(mode, "ic", function()
                select.select_textobject("@class.inner", "textobjects")
            end)

            vim.keymap.set(mode, "aa", function()
                select.select_textobject("@parameter.outer", "textobjects")
            end)

            vim.keymap.set(mode, "ia", function()
                select.select_textobject("@parameter.inner", "textobjects")
            end)

            vim.keymap.set(mode, "ab", function()
                select.select_textobject("@block.outer", "textobjects")
            end)

            vim.keymap.set(mode, "ib", function()
                select.select_textobject("@block.inner", "textobjects")
            end)
        end

        local move_keys = {
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
                ["]a"] = "@parameter.inner",
            },

            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]C"] = "@class.outer",
                ["]A"] = "@parameter.inner",
            },

            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[a"] = "@parameter.inner",
            },

            goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[C"] = "@class.outer",
                ["[A"] = "@parameter.inner",
            },
        }

        local function attach(buf)
            for method, keymaps in pairs(move_keys) do
                for key, query in pairs(keymaps) do
                    local desc = query:gsub("@", ""):gsub("%..*", "")
                    desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc

                    if not (vim.wo.diff and key:find("[cC]")) then
                        vim.keymap.set({ "n", "x", "o" }, key, function()
                            require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
                        end, {
                            buffer = buf,
                            desc = desc,
                            silent = true,
                        })
                    end
                end
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("ts_textobjects", { clear = true }),
            callback = function(ev)
                attach(ev.buf)
            end,
        })

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
                attach(buf)
            end
        end
    end,
}
