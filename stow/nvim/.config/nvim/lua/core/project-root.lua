-- lua/core/project-root.lua

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("ProjectRoot", { clear = true }),
  callback = function()
    local root = vim.fs.root(0, {
      ".git",
      "package.json",
      "pom.xml",
      "build.gradle",
      "settings.gradle",
    })

    if root then
      vim.cmd.cd(root)
    end
  end,
})
