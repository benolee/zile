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



--[[ ========================= ]]--
--[[ ZLisp scanner and parser. ]]--
--[[ ========================= ]]--


-- Increment index into s and return that character.
local function read_char (s, pos)
  if pos <= #s then
    return s[pos], pos + 1
  end
  return -1, pos
end


-- Lexical scanner: Return three values: `token', `kind', `i', where
-- `token' is the content of the just scanned token, `kind' is the
-- type of token returned, and `i' is the index of the next unscanned
-- character in `s'.
local function read_token (s, pos)
  local c
  local doublequotes = false
  local tok = ""

  -- Chew space to next token
  repeat
    c, pos = read_char (s, pos)

    -- Munch comments
    if c == ";" then
      repeat
        c, pos = read_char (s, pos)
      until c == -1 or c == "\n"
    end
  until c ~= " " and c ~= "\t"

  -- Snag token
  if c == "(" or c == ")" or c == "'" or c == "\n" or c == -1 then
    return tok, c, pos
  end

  -- It looks like a string. Snag to the next whitespace.
  if c == "\"" then
    doublequotes = true
    c, pos = read_char (s, pos)
  end

  repeat
    tok = tok .. c
    if not doublequotes then
      if c == ")" or c == "(" or c == ";" or c == " " or c == "\n"
        or c == "\r" or c == -1 then
        pos = pos - 1
        tok = string.sub (tok, 1, -2)
        return tok, "word", pos
      end
    else
      if c == "\n" or c == "\r" or c == -1 then
        pos = pos - 1
      end
      if c == "\"" then
        tok = string.sub (tok, 1, -2)
        return tok, "word", pos
      end
    end
    c, pos = read_char (s, pos)
  until false
end


-- Call scanner  repeatedly to build and return an abstract syntax-tree
-- representation of the ZLisp code in `s'.
local function lisp_read (s)
  local pos = 1
  local function append (l, e)
    if l == nil then
      l = e
    else
      local l2 = l
      while l2.next ~= nil do
        l2 = l2.next
      end
      l2.next = e
    end
    return l
  end
  local function read ()
    local l = nil
    local quoted = false
    repeat
      local tok, tokenid
      tok, tokenid, pos = read_token (s, pos)
      if tokenid == "'" then
        quoted = true
      else
        if tokenid == "(" then
          l = append (l, {branch = read (), quoted = quoted})
        elseif tokenid == "word" then
          l = append (l, {data = tok, quoted = quoted})
        end
        quoted = false
      end
    until tokenid == ")" or tokenid == -1
    return l
  end

  return read ()
end



--[[ ======================== ]]--
--[[ Symbol Table Management. ]]--
--[[ ======================== ]]--


-- ZLisp symbols.
local symbol = {}


-- Define symbols for the evaluator.
function M.Defun (name, argtypes, doc, interactive, func)
  symbol[name] = {
    doc = texi (doc:chomp ()),
    interactive = interactive,
    func = function (arglist)
             local args = {}
             local i = 1
             while arglist and arglist.next do
               local val = arglist.next
               local ty = argtypes[i]
               if ty == "number" then
                 val = tonumber (val.data, 10)
               elseif ty == "boolean" then
                 val = val.data ~= "nil"
               elseif ty == "string" then
                 val = tostring (val.data)
               end
               table.insert (args, val)
               arglist = arglist.next
               i = i + 1
             end
             current_prefix_arg = prefix_arg
             prefix_arg = false
             local ret = func (unpack (args))
             if ret == nil then
               ret = true
             end
             return ret
           end
  }
end


-- Return true if there is a symbol `name' in the symbol-table.
function M.function_exists (name)
  return symbol[name] ~= nil
end


-- Return function's interactive field, or nil if not found.
function M.get_function_interactive (name)
  return symbol[name] and symbol[name].interactive or nil
end


-- Return the docstring for symbol `name'.
function M.get_function_doc (name)
  return symbol[name] and symbol[name].doc or nil
end


-- Iterator returning (name, entry) for each symbol.
function M.commands ()
  return next, symbol, nil
end



--[[ ================ ]]--
--[[ ZLisp Evaluator. ]]--
--[[ ================ ]]--


-- Execute a function non-interactively.
function M.execute_function (name, uniarg)
  local ok

  if uniarg ~= nil and type (uniarg) ~= "table" then
    uniarg = {next = {data = uniarg and tostring (uniarg) or nil}}
  end

  command.attach_label (nil)
  ok = symbol[name] and symbol[name].func and symbol[name].func (uniarg)
  command.next_label ()

  return ok
end

-- Call an interactive command.
function M.call_command (f, branch)
  thisflag = {defining_macro = lastflag.defining_macro}

  -- Execute the command.
  command.interactive_enter ()
  local ok = M.execute_function (f, branch)
  command.interactive_exit ()

  -- Only add keystrokes if we were already in macro defining mode
  -- before the function call, to cope with start-kbd-macro.
  if lastflag.defining_macro and thisflag.defining_macro then
    add_cmd_to_macro ()
  end

  if cur_bp and not command.was_labelled (":undo") then
    cur_bp.next_undop = cur_bp.last_undop
  end

  lastflag = thisflag

  return ok
end


-- Evalute one branch of the AST.
local function evaluateBranch (branch)
  return branch and branch.data and M.call_command (branch.data, branch) or nil
end


-- Evaluate an AST.
local function leEval (list)
  while list do
    evaluateBranch (list.branch)
    list = list.next
  end
end


-- This needs to be accessible for writing special forms that only
-- evaluate some of their arguments, e.g. setq.
function M.evaluateNode (node)
  if node == nil then
    return nil
  end
  local value
  if node.branch ~= nil then
    if node.quoted then
      value = node.branch
    else
      value = evaluateBranch (node.branch)
    end
  else
    value = {data = get_variable (node.data) or node.data}
  end
  return value
end


-- Evaluate a string of ZLisp.
function M.loadstring (s)
  leEval (lisp_read (s))
end


-- Evaluate a file of ZLisp.
function M.loadfile (file)
  local s = io.slurp (file)

  if s then
    M.loadstring (s)
    return true
  end

  return false
end


return M
