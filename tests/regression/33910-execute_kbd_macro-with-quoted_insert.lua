;;; FIXME: Although F1 usually outputs ^[OP, this test will fail
;;;        when the terminal outputs something else instead.

;; quoted_insert F1 RETURN
;; save_buffer save_buffers_kill_zi
(execute_kbd_macro "\C-q\F1\RET\C-x\C-s\C-x\C-c")
