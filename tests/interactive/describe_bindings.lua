; describe_bindings other_window set_mark goto_line 2 RET copy_region_as_kill
; other_window yank save_buffer save_buffers_kill_zi
(execute_kbd_macro "\M-xdescribe_bindings\r\C-xo\C-@\M-gg2\r\ew\C-xo\C-y\C-x\C-s\C-x\C-c")
