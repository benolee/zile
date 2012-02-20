-- ESC 1 ESC ! "echo foo" \M-x RET
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\e1\\e!echo foo\\M-x\\r\\C-x\\C-s\\C-x\\C-c"
