;;; Regression:
;;; crash when creating suffixed buffers for files with the same name

; find_file a/f RET find_file b/f RET kill_buffer RET kill_buffer RET
; save_buffer save_buffers_kill_zi
(execute_kbd_macro "\C-x\C-fa/f\r\C-x\C-fb/f\r\C-xk\r\C-xk\r\C-x\C-s\C-x\C-c")
