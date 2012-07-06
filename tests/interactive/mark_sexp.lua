-- forward_word ( ESC 3 forward_word ) backward_word backward_word ESC 5
-- backward_char mark_sexp kill_region save_buffer save_buffers_kill_zi
execute_kbd_macro "\\A-f(\\e3\\A-f)\\A-b\\A-b\\e5\\C-b\\C-\\A-@\\C-w\\C-x\\C-s\\C-x\\C-c"
