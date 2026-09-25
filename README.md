# The most useless nvim plugin ever
## Background
I have once heard a fascinating factoid:

> If you scramble all the letters in a word, excluding the first and last, it will still be (mostly) legible to most people.

In order to experience this more dynamically, I have created this plugin.

It provides one command: `:ScrambleBuffer`.
It scrambles the inner letters of all words.

## Installation
To install with lazy:
```lua
{
  "sav-imagines/dyslexia-emulator",
  opts = {},
}
```

## Configuration
You can provide a threshold (0-1) for how often you want a word to be scrambled:
0 means everything, and 1 means everything will be scrambled.
```lua
{
  threshold = 0.9
}
```

For extra fun, set a BufWritePre autocmd :)
you will not regret the word scrambler autocmd

To do this (very reasonable indeed) setup:
```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.txt", "*.md" },
  callback = function()
    require("dyslexia-emulator").scramble_buffer()
  end,
  desc = "Scramble buffer before writing",
})
```
For this, it is recommended to set threshold to at least `.9`.
