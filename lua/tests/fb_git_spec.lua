local fb_git = require "telescope._extensions.file_browser.git"
local Path = require "plenary.path"

describe("parse_status_output", function()
  local cwd = Path:new({ "project", "root", "dir" }).filename
  local finders_path = Path:new({ "lua", "telescope", "_extensions", "file_browser", "finders.lua" }).filename
  local test_dir = Path:new({ "lua", "tests" }).filename
  it("works in the root dir", function()
    local git_status = {
      "M  .gitignore",
      " M README.md",
      " M " .. finders_path,
      "?? " .. test_dir,
    }
    local expect = {
      [Path:new({ cwd, ".gitignore" }).filename] = "M ",
      [Path:new({ cwd, "README.md" }).filename] = " M",
      [Path:new { cwd, finders_path }] = " M",
      [Path:new { cwd, test_dir }] = "??",
    }
    local actual = fb_git.parse_status_output(git_status, cwd)
    assert.are.same(expect, actual)
  end)

  it("works in a sub dir", function()
    local git_status = {
      " M lua/telescope/_extensions/file_browser/finders.lua",
      "?? lua/tests/",
    }
    local expect = {
      [cwd .. "/lua/telescope/_extensions/file_browser/finders.lua"] = " M",
      [cwd .. "/lua/tests/"] = "??",
    }
    local actual = fb_git.parse_status_output(git_status, cwd)
    assert.are.same(expect, actual)
  end)

  it("parses renamed and copied status", function()
    local git_status = {
      "R  lua/telescope/_extensions/file_browser/stats.lua -> lua/telescope/_extensions/file_browser/fs_stat.lua",
      "C  lua/telescope/_extensions/file_browser/stats.lua -> lua/telescope/_extensions/file_browser/fs_stat.lua",
      " M lua/telescope/_extensions/file_browser/make_entry.lua",
    }
    local expect = {
      [cwd .. "/lua/telescope/_extensions/file_browser/fs_stat.lua"] = "R ",
      [cwd .. "/lua/telescope/_extensions/file_browser/fs_stat.lua"] = "C ",
      [cwd .. "/lua/telescope/_extensions/file_browser/make_entry.lua"] = " M",
    }
    local actual = fb_git.parse_status_output(git_status, cwd)
    assert.are.same(expect, actual)
  end)
end)
