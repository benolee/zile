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

-- Key modifiers.
local KBD_CTRL = 512
local KBD_ALT = 1024

-- Common non-alphanumeric keys.
local KBD_CANCEL = 257
local KBD_TAB = 258
local KBD_RET = 259
local KBD_PGUP = 260
local KBD_PGDN = 261
local KBD_HOME = 262
local KBD_END = 263
local KBD_DEL = 264
local KBD_BS = 265
local KBD_INS = 266
local KBD_LEFT = 267
local KBD_RIGHT = 268
local KBD_UP = 269
local KBD_DOWN = 270
local KBD_F1 = 272
local KBD_F2 = 273
local KBD_F3 = 274
local KBD_F4 = 275
local KBD_F5 = 276
local KBD_F6 = 277
local KBD_F7 = 278
local KBD_F8 = 279
local KBD_F9 = 280
local KBD_F10 = 281
local KBD_F11 = 282
local KBD_F12 = 283

-- Modifiers
local modifier = {
  ["C"]         = KBD_CTRL,
  ["A"]         = KBD_ALT,
}

-- Array of key names
local keynametocode_map = {
  ["backslash"] = string.byte ('\\'),
  ["backspace"] = KBD_BS,
  ["cancel"]    = string.byte ('\a'),
  ["delete"]    = KBD_DEL,
  ["down"]      = KBD_DOWN,
  ["end"]       = KBD_END,
  ["enter"]     = string.byte ('\n'),
  ["escape"]    = 27,
  ["f1"]        = KBD_F1,
  ["f10"]       = KBD_F10,
  ["f11"]       = KBD_F11,
  ["f12"]       = KBD_F12,
  ["f2"]        = KBD_F2,
  ["f3"]        = KBD_F3,
  ["f4"]        = KBD_F4,
  ["f5"]        = KBD_F5,
  ["f6"]        = KBD_F6,
  ["f7"]        = KBD_F7,
  ["f8"]        = KBD_F8,
  ["f9"]        = KBD_F9,
  ["formfeed"]  = string.byte ('\f'),
  ["home"]      = KBD_HOME,
  ["insert"]    = KBD_INS,
  ["left"]      = KBD_LEFT,
  ["pgdn"]      = KBD_PGDN,
  ["pgup"]      = KBD_PGUP,
  ["return"]    = KBD_RET,
  ["right"]     = KBD_RIGHT,
  ["space"]     = string.byte (' '),
  ["tab"]       = KBD_TAB,
  ["up"]        = KBD_UP,
  ["vtab"]      = string.byte ('\v'),
}

-- Insert printable characters in the ASCII range.
for i=0x0,0x7f do
  if posix.isprint (string.char (i)) and i ~= string.byte ('\\') and i ~= string.byte (' ') then
    keynametocode_map[string.char (i)] = i
  end
end

local function mapkey (map, key, mod)
  if not key then
    return "invalid keycode: nil"
  end

  local s = (key.CTRL and mod.C or "") .. (key.ALT and mod.A or "")

  if not key.key then
    return "invalid keycode: " .. s .. "nil"
  end

  if map[key.key] then
    s = s .. map[key.key]
  elseif key.key <= 0xff and posix.isgraph (string.char (key.key)) then
    s = s .. string.char (key.key)
  else
    s = s .. string.format ("<%x>", key.key)
  end

  return s
end

local keyreadsyntax_map = table.invert (keynametocode_map)

-- Convert an internal format key chord back to its read syntax
local function toreadsyntax (key)
  return mapkey (keyreadsyntax_map, key, {C = "\\C-", A = "\\A-"})
end

-- For quick reverse lookups:
local codetoname = table.invert (keynametocode_map)

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

    if codetoname[self.key] then
      s = s .. codetoname[self.key]
    elseif self.key <= 0xff and posix.isgraph (string.char (self.key)) then
      s = s .. string.char (self.key)
    else
      s = s .. string.format ("<%x>", self.key)
    end

    return s
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
  key.key = keynametocode_map[chord]

  if not key.key then
    -- Extract the keypress proper from the end of the string.
    key.key = keynametocode_map[chord:match ("[^%s%-]*%-?$")]
    if not key.key then return nil end

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
