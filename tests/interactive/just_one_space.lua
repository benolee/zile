-- forward_word SPC SPC SPC just_one_space insert "a"
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\A-f   \\A- a\\C-x\\C-s\\C-x\\C-c"
