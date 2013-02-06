-- Zile Lisp interpreter
--
-- Copyright (c) 2009-2013 Free Software Foundation, Inc.
--
-- This file is part of GNU Zile.
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
-- along with this program; see the file COPYING.  If not, write to the
-- Free Software Foundation, Fifth Floor, 51 Franklin Street, Boston,
-- MA 02111-1301, USA.


local M = {}



--[[ ----------- ]]--
--[[ Cons Cells. ]]--
--[[ ----------- ]]--


local Cons = {}
local metatable = { __index = Cons }


-- Construct and return a new cons cell:
--   new = M.cons (car, cdr)
function M.cons (car, cdr)
  return setmetatable ({car = car, cdr = cdr}, metatable)
end


-- Return the nth element of a list of cons cells.
function Cons:nth (n)
  if type (n) ~= "number" or n < 1 or self == nil then
    return nil
  elseif n == 1 then
    return self.car
  end

  -- Weird calling convention to enable tail call elimination.
  return Cons.nth (self.cdr, n - 1)
end


-- For iterator over a list of cons cells.
--   for _, car in list:cars () do ... end
function Cons:cars ()
  -- Lua `for' always passes the entire list on every iteration, so
  -- we have to return sublist containing the actual value each time
  -- to get it back in `rest' on the following call.
  local function iter (list, rest)
    if rest == nil then return list, list.car end
    if rest.cdr ~= nil then return rest.cdr, rest.cdr.car end
    return nil, rest.car
  end
  return iter, self, nil
end


-- Equivalent to table.concat for lists of cons cells.  Concatenates
-- value field of each car if available, otherwise all of car itself.
function Cons:concat (delim)
  delim = delim or ""
  local s = tostring (self.car.value or self.car)
  if self.cdr == nil then return s end
  return s .. delim .. Cons.concat (self.cdr, delim)
end


-- Return a non-destructive reversed cons list.
function Cons:reverse ()
  local rev = nil
  for _, car in self:cars () do
    rev = M.cons (car, rev)
  end
  return rev
end



--[[ --------------------------- ]]--
--[[ Sets that work with strict. ]]--
--[[ --------------------------- ]]--


local _mt, Set

_mt = {
  -- Return a new set containing the union of values from s and t.
  __add = function (s, t)
    local r = Set ()
    for k in pairs (s) do rawset (r, k, true) end
    for k in pairs (t) do rawset (r, k, true) end
    return r
 end,
}


Set = setmetatable ({}, {
  -- Return a new set containing values from t.
  __call = function (s, t)
    local r = setmetatable ({}, _mt)
    if t ~= nil then
      for _, v in pairs (t) do rawset (r, v, true) end
    end
    return r
  end,
})



--[[ ========================= ]]--
--[[ ZLisp scanner and parser. ]]--
--[[ ========================= ]]--


local isskipped   = Set { ";", " ", "\t", "\n", "\r" }
local isoperator  = Set { "(", ")", "'" }
local isdelimiter = Set { '"' } + isskipped + isoperator


-- Return the 1-based line number at which offset `o' occurs in `s'.
local function iton (s, i)
  local n = 1
  for _ in string.gmatch (s:sub (1, i), "\n") do n = n + 1 end
  return n
end


-- Increment index into s and return that character.
local function nextch (s, i)
  return i < #s and s[i + 1] or nil, i + 1
end


-- Lexical scanner: Return three values: `token', `kind', `i', where
-- `token' is the content of the just scanned token, `kind' is the
-- type of token returned, and `i' is the index of the next unscanned
-- character in `s'.
local function lex (s, i)
  -- Skip initial whitespace and comments.
  local c
  repeat
    c, i = nextch (s, i)

    -- Comments start with `;'.
    if c == ';' then
      repeat
        c, i = nextch (s, i)
      until c == '\n' or c == '\r' or c == nil
    end

    -- Continue skipping additional lines of comments and whitespace.
  until c == nil or not isskipped[c]

  -- Return end-of-file immediately.
  if c == nil then return nil, "eof", i end

  -- Return operator tokens.
  -- These are returned in the `kind' field so we can immediately tell
  -- the difference between a ')' delimiter and a ")" string token.
  if isoperator[c] then
    return "", c, i
  end

  -- Strings start and end with `"'.
  -- Note we read another character immediately to skip the opening
  -- quote, and don't append the closing quote to the returned token.
  local token = ''
  if c == '"' then
    repeat
      c, i = nextch (s, i)
      if c == nil then
        return token, "incomplete string", i - 1
      elseif c ~= '"' then
        token = token .. c
      end
    until c == '"'

    return token, "string", i
  end

  -- Anything else is a `word' - up to the next whitespace or delimiter.
  repeat
    token = token .. c
    c, i = nextch (s, i)
    if isdelimiter[c] or c == nil then
      return token, "word", i - 1
    end
  until false
end


-- Call `lex' repeatedly to build and return an abstract syntax-tree
-- representation of the ZLisp code in `s'.
function M.parse (s)
  local i = 0

  -- New nodes are pushed onto the front of the list for speed...
  local function push (ast, value, kind, quoted)
    return M.cons ({value = value, kind = kind, quoted = quoted}, ast)
  end

  local function read (nested, openparen)
    local ast, token, kind, quoted
    repeat
      token, kind, i = lex (s, i)
      if kind == "'" then
        quoted = kind
      else
        if kind == "(" then
	  local subtree, errmsg = read (true, i)
	  if errmsg ~= nil then return ok, errmsg end
          ast = push (ast, subtree, nil, quoted)

        elseif kind == "word" or kind == "string" then
          ast = push (ast, token, kind, quoted)

	elseif kind == ")" then
          if not nested then
            return nil, iton (s, i) .. ": unmatched close parenthesis"
	  end
	  openparen = nil
	  break

        elseif kind == "incomplete string" then
          return nil, iton (s, i) .. ": incomplete string"
        end
        quoted = nil
      end
    until kind == "eof"

    if openparen ~= nil then
      return nil, iton (s, openparen) .. ": unmatched open parenthesis"
    end

    -- ...and then the whole list is reversed once completed.
    return ast and ast:reverse () or nil
  end

  -- `false' argument allows detection of unmatched outer `)' tokens.
  return read (false)
end



--[[ ======================== ]]--
--[[ Symbol Table Management. ]]--
--[[ ======================== ]]--


-- ZLisp symbols.
M.symbol = {}


-- Define a new symbol.
function M.define (name, value)
  M.symbol[name] = value
end


-- Iterator returning (name, entry) for each symbol.
function M.symbols ()
  return next, M.symbol, nil
end



--[[ ================ ]]--
--[[ ZLisp Evaluator. ]]--
--[[ ================ ]]--


-- Execute a function non-interactively.
function M.call_command (name, arglist)
  local value = M.symbol[name]
  return value and type (value) == "function" and value (arglist) or nil
end


-- Evaluate a list of command expressions.
local function evalexpr (list)
  return list and list.car and M.call_command (list.car.value, list.cdr) or nil
end


-- Evaluate a string of ZLisp.
function M.evalstring (s)
  local ast, errmsg = M.parse (s)
  if ast == nil then
    return nil, errmsg
  end

  for _, car in Cons.cars (ast) do
    evalexpr (car.value)
  end
  return true
end


-- Evaluate a file of ZLisp.
function M.evalfile (file)
  local s, errmsg = io.slurp (file)

  if s then
    s, errmsg = M.evalstring (s)
  end

  return s, errmsg
end


return M
