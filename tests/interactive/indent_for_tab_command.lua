-- goto_line 1 RET indent_for_tab_command
-- goto_line 2 RET indent_for_tab_command
-- goto_line 4 RET indent_for_tab_command
-- indent_for_tab_command save_buffer save_buffers_kill_zi
execute_kbd_macro "a-g g 1 return tab a-g g 2 return tab a-g g 4 return tab c-x c-s c-x c-c"
