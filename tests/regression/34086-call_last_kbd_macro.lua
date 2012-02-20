-- start_kbd_macro "foo" RET UP end_kbd_macro
-- prefix_cmd 3 call_last_kbd_macro save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-x(foo\\r\\UP\\C-x)\\e3\\C-xe\\C-x\\C-s\\C-x\\C-c"
