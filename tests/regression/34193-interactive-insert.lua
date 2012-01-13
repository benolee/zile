;;; Regression:
;;; crash after accepting an empty argument to insert

; insert RET
; save_buffer save_buffers_kill_zi
(execute_kbd_macro "\M-xinsert\r\C-g\C-x\C-s\C-x\C-c")
