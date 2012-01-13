-- Zi variables
--
-- Copyright (c) 1997-2010, 2012 Free Software Foundation, Inc.
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

X ("inhibit_splash_screen", "nil", false, "Non-nil inhibits the startup screen.\nIt also inhibits display of the initial message in the `*scratch*' buffer.")
X ("standard_indent", "4", false, "Default number of columns for margin-changing functions to indent.")
X ("tab_width", "8", true, "Distance between tab stops (for display of tab characters), in columns.")
X ("tab_always_indent", "t", false, "Controls the operation of the @kbd{TAB} key.\nIf @samp{t}, hitting @kbd{TAB} always just indents the current line.\nIf @samp{nil}, hitting @kbd{TAB} indents the current line if point is at the\nleft margin or in the line's indentation, otherwise it inserts a\n\"real\" TAB character.")
X ("indent_tabs_mode", "t", true, "If non-nil, insert_tab inserts \"real\" tabs; otherwise, it always inserts\nspaces.")
X ("fill_column", "70", true, "Column beyond which automatic line-wrapping should happen.\nAutomatically becomes buffer-local when set in any fashion.")
X ("auto_fill_mode", "nil", false, "If non-nil, Auto Fill Mode is automatically enabled.")
X ("kill_whole_line", "nil", false, "If non-nil, `kill_line' with no arg at beg of line kills the whole line.")
X ("case_fold_search", "t", true, "Non-nil means searches ignore case.")
X ("case_replace", "t", false, "Non-nil means `query_replace' should preserve case in replacements.")
X ("ring_bell", "t", false, "Non-nil means ring the terminal bell on any error.")
X ("highlight_nonselected_windows", "nil", false, "If non-nil, highlight region even in nonselected windows.")
X ("make_backup_files", "t", false, "Non-nil means make a backup of a file the first time it is saved.\nThis is done by appending `@samp{~}' to the file name.")
X ("backup_directory", "nil", false, "The directory for backup files, which must exist.\nIf this variable is @samp{nil}, the backup is made in the original file's\ndirectory.\nThis value is used only when `make_backup_files' is @samp{t}.")
