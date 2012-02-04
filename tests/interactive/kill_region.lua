-- set_mark goto_line 3 RET kill_region
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "c-@ a-g g 3 return c-w c-x c-s c-x c-c"
