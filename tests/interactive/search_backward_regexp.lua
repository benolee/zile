; end_of_buffer search_backward_regexp l . n RET a
; save_buffer save_buffers_kill_zi
(execute_kbd_macro "\M->\M-xsearch_backward_regexp\rl.n\ra\C-x\C-s\C-x\C-c")
