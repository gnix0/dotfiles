return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },

  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {
      filewatching = "roslyn",
      broad_search = true,
      lock_target = true,
      silent = false,
    },
    config = function(_, opts)
      vim.lsp.config("roslyn", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        on_attach = function(client, bufnr)
          vim.notify("Roslyn LSP: Connected to " .. vim.fn.expand("%:t"), "info")
        end,
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_provide_regex_completions = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true,
          },
          ["csharp|navigation"] = {
            dotnet_navigate_to_decompiled_sources = true,
          },
          ["csharp|implement_type"] = {
            dotnet_implement_type_property_generation_behavior = "PreferAutoProperties",
          },
          ["csharp|highlighting"] = {
            dotnet_highlight_related_regex_components = true,
            dotnet_hightlight_related_json_components = true,
          },
          ["csharp|format"] = {
            dotnet_organize_imports_on_format = true,
          },
          ["csharp|quick_info"] = {
            dotnet_show_remarks_in_quick_info = true,
          },
        },
      })

      require("roslyn").setup(opts)
    end,
  },
}
