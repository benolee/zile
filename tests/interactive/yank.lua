-- set_mark goto_line 3 RET kill_region end_of_buffer yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-@\\A-gg3\\r\\C-w\\A->\\C-y\\C-x\\C-s\\C-x\\C-c"
