-- Key encoding and decoding functions
--
-- Copyright (c) 2010-2012 Free Software Foundation, Inc.
--
-- This file is part of GNU Zi.
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Modifiers
local modifier_names = { "A", "C" }

-- Array of key names
local is_key = set.new ({
  "backslash",
  "backspace",
  "cancel",
  "delete",
  "down",
  "end",
  "enter",
  "escape",
  "f1",
  "f10",
  "f11",
  "f12",
  "f2",
  "f3",
  "f4",
  "f5",
  "f6",
  "f7",
  "f8",
  "f9",
  "formfeed",
  "home",
  "insert",
  "left",
  "pgdn",
  "pgup",
  "return",
  "right",
  "space",
  "tab",
  "up",
  "vtab",
})

-- Insert printable characters in the ASCII range.
for i=0x0,0x7f do
  if posix.isprint (string.char (i)) then
    set.insert (is_key, string.char (i))
  end
end


-- A key code has one `keypress' and some optional modifiers.
-- For comparisons to work, keycodes are immutable atoms.
local keycode_mt = {
  -- Output the write syntax for this keycode (e.g. C-A-<f1>).
  __tostring = function (self)
    if not self or not self.key then
      return "invalid keycode: nil"
    end

    local s = ""
    list.map (function (e)
                if self[e] then s = s .. e .. "-" end
              end, modifier_names)

    return s .. self.key
  end,

  -- Normalise modifier lookups to uppercase, sans `-' suffix.
  --   hasmodifier = keycode.ALT or keycode["c"]
  __index = function (self, mod)
    mod = string.upper (string.sub (mod, 1, 1))
    return rawget (self, mod)
  end,

  -- Return the immutable atom for this keycode with modifier added.
  --   ctrlkey = "c-" + key
  __add = function (self, mod)
    if type (self) == "string" then mod, self = self, mod end
    mod = string.upper (string.sub (mod, 1, 1))
    if self[mod] then return self end
    return keycode (mod .. "-" .. tostring (self))
  end,

  -- Return the immutable atom for this keycode with modifier removed.
  --   withoutalt = key - "a-"
  __sub = function (self, mod)
    if type (self) == "string" then mod, self = self, mod end
    mod = string.upper (string.sub (mod, 1, 1))
    local keystr = string.gsub (tostring (self), mod .. "%-", "")
    return keycode (keystr)
  end,
}


local is_modifier = set.new (modifier_names)

-- Convert a single keychord string to its key code.
keycode = memoize (function (chord)
  -- Normalise modifiers to upper case before creating an atom.
  if chord:match ("%l%-") then
    local l = chord:match ("[^%s%-]*%-?$")
    for e in chord:gmatch ("[^%s%-]+%-") do
      l = string.upper (e) .. l
    end
    return keycode (l)
  end

  local key = setmetatable ({}, keycode_mt)
  if chord ~= nil then
    -- Extract the keypress proper from the end of the string.
    key.key = chord:match ("[^%s%-]*%-?$")
    if not is_key[key.key] then return nil end

    -- Extract "-" suffixed modifiers from the beginning of the string.
    for e in chord:gmatch ("([^%s%-]+)%-") do
      if is_modifier[e] then
        if key[e] then
          return nil, chord .. ": " .. e .. " specified more than once"
	end
	key[e] = true
      else
        return nil, chord .. ": unknown modifier " .. e
      end
    end
  end

  -- Normalise modifiers so that C-A-r and A-C-r are the same
  -- atom.
  local k = (key.CTRL and "C-" or "") .. (key.ALT and "A-" or "") .. chord:match ("[^%s%-]*%-?$")
  if k ~= chord then return keycode (k) end

  return key
end)

-- Convert a key sequence string into a key code sequence, or nil if
-- it can't be converted.
function keystrtovec (s)
  local keys = setmetatable ({}, {
    __tostring = function (self)
                   return table.concat (list.map (tostring, self), " ")
                 end
  })

  for substr in s:gmatch ("%S+") do
    local key = keycode (substr)
    if key == nil then
      return nil
    end
    table.insert (keys, key)
  end

  return keys
end
