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
local modifier = {
  ["C"]         = true,
  ["A"]         = true,
}

-- Array of key names
local keynametocode_map = {
  ["backslash"] = true,
  ["backspace"] = true,
  ["cancel"]    = true,
  ["delete"]    = true,
  ["down"]      = true,
  ["end"]       = true,
  ["enter"]     = true,
  ["escape"]    = true,
  ["f1"]        = true,
  ["f10"]       = true,
  ["f11"]       = true,
  ["f12"]       = true,
  ["f2"]        = true,
  ["f3"]        = true,
  ["f4"]        = true,
  ["f5"]        = true,
  ["f6"]        = true,
  ["f7"]        = true,
  ["f8"]        = true,
  ["f9"]        = true,
  ["formfeed"]  = true,
  ["home"]      = true,
  ["insert"]    = true,
  ["left"]      = true,
  ["pgdn"]      = true,
  ["pgup"]      = true,
  ["return"]    = true,
  ["right"]     = true,
  ["space"]     = true,
  ["tab"]       = true,
  ["up"]        = true,
  ["vtab"]      = true,
}

-- Insert printable characters in the ASCII range.
for i=0x0,0x7f do
  if posix.isprint (string.char (i)) and i ~= string.byte ('\\') and i ~= string.byte (' ') then
    keynametocode_map[string.char (i)] = true
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
                if self[e] then s = s .. e end
              end, { "C-", "A-" })

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
    if not keynametocode_map[key.key] then return nil end

    -- Extract "-" suffixed modifiers from the beginning of the string.
    for e in chord:gmatch ("([^%s%-]+)%-") do
      if modifier[e] then
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
