-- start_kbd_macro "foo" RET UP end_kbd_macro
-- prefix_cmd 3 call_last_kbd_macro save_buffer save_buffers_kill_zi
execute_kbd_macro "c-x ( f o o return up c-x ) escape 3 c-x e c-x c-s c-x c-c"
