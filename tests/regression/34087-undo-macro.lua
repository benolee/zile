-- start_kbd_macro foo RET end_kbd_macro call_last_kbd_macro undo
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "c-x ( f o o return c-x ) c-x e c-_ c-x c-s c-x c-c"
