vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "/home/jschreuder/git/ansible/*",
  callback = function()
    vim.bo.filetype = "yaml.ansible"
  end,
})
