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

    -- Continue skipping, additional lines of comments and whitespace.
  until c ~= ' ' and c ~= '\t' and c ~= '\n' and c ~= '\r'

  -- Return end-of-file immediately.
  if c == nil then return nil, "eof", i end

  -- Return delimiter tokens.
  -- These are returned in the kind field so we can immediately tell
  -- the difference between a ')' delimiter and a ")" string token.
  if c == '(' or c == ')' or c == "'" then
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
  -- Try to compare common characters first to minimise time spent
  -- checking.
  repeat
    token = token .. c
    c, i = nextch (s, i)
    if c == ')' or c == '(' or c == ';' or c == ' ' or c == '\t'
       or c == '\n' or c == '\r' or c == "'" or c == nil
    then
      return token, "word", i - 1
    end
  until false
end


-- Call `lex' repeatedly to build and return an abstract syntax-tree
-- representation of the ZLisp code in `s'.
local function parse (s)
  local i = 0
  local function append (ast, e)
    if ast == nil then
      ast = e
    else
      local l2 = ast
      while l2.next ~= nil do
        l2 = l2.next
      end
      l2.next = e
    end
    return ast
  end
  local function read ()
    local ast = nil
    local quoted = false
    repeat
      local token, kind
      token, kind, i = lex (s, i)
      if kind == "'" then
        quoted = true
      else
        if kind == "(" then
          ast = append (ast, {branch = read (), quoted = quoted})
        elseif kind == "word" then
          ast = append (ast, {data = token, quoted = quoted})
	elseif kind == "string" then
          ast = append (ast, {data = token, string = true, quoted = quoted})
        end
        quoted = false
      end
    until kind == ")" or kind == "eof"
    return ast
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
  leEval (parse (s))
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
