-- goto_line 1 RET indent_for_tab_command
-- goto_line 2 RET indent_for_tab_command
-- goto_line 4 RET indent_for_tab_command
-- indent_for_tab_command save_buffer save_buffers_kill_zi
execute_kbd_macro "\\A-gg1\\r\\t\\A-gg2\\r\\t\\A-gg4\\r\\t\\C-x\\C-s\\C-x\\C-c"
