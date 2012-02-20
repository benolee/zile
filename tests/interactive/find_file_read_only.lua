-- kill_buffer RET find_file_read_only "tests/interactive/find_file_read_only.input" save_buffers save_buffers_kill_zi
execute_kbd_macro "\\C-xk\\r\\C-x\\C-rtests/interactive/find_file_read_only.input\\r\\C-x\\C-s\\C-x\\C-c"
