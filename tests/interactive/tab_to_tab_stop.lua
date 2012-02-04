-- goto_line 3 RET tab_to_tab_stop tab_to_tab_stop t a b
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "a-g g 3 return a-i a-i t a b c-x c-s c-x c-c"
