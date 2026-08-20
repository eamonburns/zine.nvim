-- Sources for Zine 0.13
-- Taken from <https://github.com/kristoff-it/zine/blob/v0.13.0/build.zig.zon>

---@class zine.Source
---@field repo string # Repository URL
---@field rev string # Git commit hash

---@type {[string]: zine.Source}
return {
  ziggy = {
    repo = "https://github.com/kristoff-it/ziggy",
    rev = "06d7ce8df16974e0ee7f897db50784d84f6b9f32",
  },
  supermd = {
    repo = "https://github.com/kristoff-it/supermd",
    rev = "da528ac38e6940d23b7c2bf611ccf01fe6231e82",
  },
  superhtml = {
    repo = "https://github.com/kristoff-it/superhtml",
    rev = "624a3eeadaf8f0cbe2e7d9d64ff621bc2d1c5d69",
  },
}
