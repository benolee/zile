-- forward_word ( ESC 3 forward_word ) backward_word backward_word ESC 5
-- backward_char mark_sexp kill_region save_buffer save_buffers_kill_zi
execute_kbd_macro "a-f ( a-3 a-f ) a-b a-b a-5 c-b c-a-@ c-w c-x c-s c-x c-c"
