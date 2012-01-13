; start_kbd_macro foo RET end_kbd_macro call_last_kbd_macro undo
; save_buffer save_buffers_kill_zi
(execute_kbd_macro "\C-x(foo\r\C-x)\C-xe\C-_\C-x\C-s\C-x\C-c")
