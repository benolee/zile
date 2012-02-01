-- run-lisp-tests
--
-- Copyright (c) 2010-2012 Free Software Foundation, Inc.
--
-- This file is part of GNU Zile.
--
-- GNU Zile is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3, or (at your option)
-- any later version.
--
-- GNU Zile is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with GNU Zile; see the file COPYING.  If not, write to the
-- Free Software Foundation, Fifth Floor, 51 Franklin Street, Boston,
-- MA 02111-1301, USA.

require "posix"
require "std"

-- N.B. Tests that use execute-kbd-macro must note that keyboard input
-- is only evaluated once the script has finished running.

-- The following are defined in the environment for a build
local srcdir = os.getenv ("srcdir") or "."
local abs_srcdir = os.getenv ("abs_srcdir") or "."
local builddir = os.getenv ("builddir") or "."

local zile_pass = 0
local zile_fail = 0
local emacs_pass = 0
local emacs_fail = 0

function mkdir_p (p)
  local st = posix.stat (p)
  if nil == st then
    mkdir_p (posix.dirname (p))
    return posix.mkdir (p)
  elseif "directory" ~= st.ftype then
    return nil, p .. ": file exists already"
  end
end

local EMACSPROG = os.getenv ("EMACSPROG") or ""

for _, name in ipairs (arg) do
  local test = string.gsub (name, "%.el$", "")
  if io.open (test .. ".output") ~= nil then
    name = posix.basename (test)
    local edit_file = io.catfile (builddir, "tests", name .. ".input")
    local args = {"--no-init-file", edit_file, "--load", io.catfile (abs_srcdir, (string.gsub (test .. ".el", "^" .. srcdir .. "/", "")))}
    local input = io.catfile (srcdir, "tests", "test.input")

    mkdir_p (posix.dirname (edit_file))

    if EMACSPROG ~= "" then
      posix.system ("cp", input, edit_file)
      posix.system ("chmod", "+w", edit_file)
      local status = posix.system (EMACSPROG, "--quick", "--batch", unpack (args))
      if status == 0 then
        if posix.system ("diff", test .. ".output", edit_file) == 0 then
          emacs_pass = emacs_pass + 1
          posix.system ("rm", "-f", edit_file, edit_file .. "~")
        else
          print ("Emacs " .. name .. " failed to produce correct output")
          emacs_fail = emacs_fail + 1
        end
      else
        print ("Emacs " .. name .. " failed to run with error code " .. tostring (status))
        emacs_fail = emacs_fail + 1
      end
    end

    posix.system ("cp", input, edit_file)
    posix.system ("chmod", "+w", edit_file)
    local status = posix.system (io.catfile (builddir, "src", "zile"), unpack (args))
    if status == 0 then
      if posix.system ("diff", test .. ".output", edit_file) == 0 then
        zile_pass = zile_pass + 1
        posix.system ("rm", "-f", edit_file, edit_file .. "~")
      else
        print ("Zile " .. name .. " failed to produce correct output")
        zile_fail = zile_fail + 1
      end
    else
      print ("Zile " .. name .. " failed to run with error code " .. tostring (status))
      zile_fail = zile_fail + 1
    end
  end
end

print (string.format ("Zile: %d pass(es) and %d failure(s)", zile_pass, zile_fail))
print (string.format ("Emacs: %d pass(es) and %d failure(s)", emacs_pass, emacs_fail))

os.exit (zile_fail + emacs_fail)
