return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    build = function()
        require("nvim-treesitter").update(nil, { summary = true })
    end,
    cmd = { "TSUpdate", "TSInstall", "TSUninstall" },
    config = function()
        local TS = require("nvim-treesitter")
        TS.setup({})

        local ensure_installed = {
            "java", "sql", "go", "bash", "c", "cpp", "diff",
            "elixir", "heex", "json", "lua", "luadoc",
            "markdown", "markdown_inline", "query", "regex",
            "ruby", "rust", "toml", "vim", "vimdoc", "xml", "yaml",
            "typescript", "javascript", "tsx", "html", "css",
        }

        local installed = TS.get_installed and TS.get_installed() or {}
        local installed_set = {}
        for _, lang in ipairs(installed) do
            installed_set[lang] = true
        end

        local to_install = vim.tbl_filter(function(lang)
            return not installed_set[lang]
        end, ensure_installed)

        if #to_install > 0 then
            TS.install(to_install, { summary = true })
        end
    end,
}
