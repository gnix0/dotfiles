return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            transparent_background = true,
            integrations = {
                alpha = true,
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                notify = true,
                mini = {
                    enabled = true,
                    indentscope = true,
                },
            },
        })

        vim.cmd.colorscheme("catppuccin")

        local hl_groups = {
            "Normal", "NormalFloat", "FloatBorder", "TelescopeNormal",
            "TelescopeBorder", "NvimTreeNormal", "NvimTreeNormalNC"
        }
        for _, group in ipairs(hl_groups) do
            vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end
    end,
}
