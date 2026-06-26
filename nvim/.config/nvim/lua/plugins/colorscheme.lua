return {
    "tanvirtin/monokai.nvim",
    name = "monokai",
    lazy = false,
    priority = 1000,
    config = function ()
        require("monokai").setup({})

        vim.cmd.colorscheme("monokai")

        local hl_groups = {
            "Normal", "NormalFloat", "FloatBorder", "TelescopeNormal", "TelescopeBorder", "NvimTreeNormal",
            "NvimTreeNormalNC", "SignColumn", "LineNr", "CursorLineNr"
        }

        for _, group in ipairs(hl_groups) do
            vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end
    end
}
