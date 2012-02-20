-- set_mark goto_line 5 RET shell_command_on_region "sort" RET
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-@\\M-gg5\\r\\C-u\\M-|sort\\r\\C-x\\C-s\\C-x\\C-c"
