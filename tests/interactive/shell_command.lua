-- shell_command "echo foo" RET save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-u\\M-!echo foo\\r\\C-x\\C-s\\C-x\\C-c"
