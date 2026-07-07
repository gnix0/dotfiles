local home = vim.env.HOME

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local ok, jdtls = pcall(require, "jdtls")
      if not ok then return end

      local mason_path = vim.fn.stdpath("data") .. "/mason"
      local jdtls_path = mason_path .. "/packages/jdtls"
      local lombok_path = jdtls_path .. "/lombok.jar"
      local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

      local function get_workspace()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        return home .. "/jdtls-workspace/" .. project_name
      end

      local function get_bundles()
        local bundles = {}
        local debug_path = mason_path .. "/packages/java-debug-adapter/extension/server"
        local debug_jar = vim.fn.glob(debug_path .. "/com.microsoft.java.debug.plugin-*.jar", true)
        if debug_jar ~= "" then table.insert(bundles, debug_jar) end

        local test_path = mason_path .. "/packages/java-test/extension/server"
        for _, j in ipairs(vim.split(vim.fn.glob(test_path .. "/*.jar", true), "\n")) do
          if j ~= "" then table.insert(bundles, j) end
        end
        return bundles
      end

      local function get_runtimes()
        local runtimes = {}

        for _, rt in ipairs({
          { name = "JavaSE-11", path = "/usr/lib/jvm/java-11-openjdk" },
          { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
          { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk" },
          { name = "JavaSE-25", path = "/usr/lib/jvm/java-25-openjdk" },
        }) do
          if vim.fn.isdirectory(rt.path) == 1 then
            table.insert(runtimes, rt)
          end
        end

        return runtimes
      end

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

      local function start_jdtls()
        local root_dir = require("jdtls.setup").find_root({
          ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle",
        })
        if not root_dir then return end
        if vim.fn.filereadable(launcher_jar) == 0 then return end

        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Xmx4g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. lombok_path,
            "-jar", launcher_jar,
            "-configuration", jdtls_path .. "/config_linux",
            "-data", get_workspace(),
          },
          root_dir = root_dir,
          settings = {
            java = {
              home = vim.env.JAVA_HOME or "/usr/lib/jvm/java-21-openjdk",
              eclipse = { downloadSources = true },
              maven = { downloadSources = true },
              referencesCodeLens = { enabled = true },
              references = { includeDecompiledSources = true },
              format = { enabled = false },
              configuration = {
                updateBuildConfiguration = "automatic",
                runtimes = get_runtimes(),
              },
              import = {
                maven = { enabled = true },
                gradle = { enabled = true },
              },
            },
          },
          capabilities = capabilities,
          init_options = {
            bundles = get_bundles(),
            extendedClientCapabilities = extendedClientCapabilities,
          },
        }

        config.on_attach = function(client, bufnr)
          vim.keymap.set("n", "<leader>co", jdtls.organize_imports, { desc = "Organize Imports", buffer = bufnr })
          vim.keymap.set("n", "<leader>ct", jdtls.test_class, { desc = "Test Class", buffer = bufnr })
          vim.keymap.set("n", "<leader>tm", jdtls.test_nearest_method, { desc = "Test Method", buffer = bufnr })
          vim.keymap.set("n", "<leader>ju", jdtls.update_project_config, { desc = "Update Project Config", buffer = bufnr })
        end

        local debug_jar = vim.fn.glob(
          mason_path .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true
        )
        if debug_jar ~= "" then
          config.handlers = {
            ["language/status"] = function(_, result)
              if result and result.type == "ServiceReady" then
                pcall(jdtls.setup_dap, { hotcodereplace = "auto", config_overrides = {} })
                pcall(require("jdtls.dap").setup_dap_main_class_configs)
              end
            end,
          }
        end

        jdtls.start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = start_jdtls,
      })

      start_jdtls()
    end,
  },
}
