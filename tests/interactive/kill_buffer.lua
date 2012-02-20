-- switch_to_buffer "*scratch*" RET kill_buffer RET a
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-xb*scratch*\\r\\C-xk\\ra\\C-x\\C-s\\C-x\\C-c"
