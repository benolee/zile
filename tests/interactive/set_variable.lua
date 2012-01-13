; set_variable "kill_whole_line" RET t RET
; kill_line save_buffer save_buffers_kill_zi
(execute_kbd_macro "\M-xset_variable\rkill_whole_line\rt\r\C-k\C-x\C-s\C-x\C-c")
