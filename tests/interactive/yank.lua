-- set_mark goto_line 3 RET kill_region end_of_buffer yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-@\\M-gg3\\r\\C-w\\M->\\C-y\\C-x\\C-s\\C-x\\C-c"
