-- Copy only into a Rust firmware project; adapt target and features.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      local ra = opts.server.default_settings["rust-analyzer"]
      ra.cargo.target = "thumbv7em-none-eabihf"
      ra.cargo.features = {}
      ra.cargo.noDefaultFeatures = true
    end,
  },
}
