-- describe_function "forward_char" RET other_window set_mark goto_line 2 RET
-- universal_argument backward_word copy_region_as_kill other_window yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\A-xdescribe_function\\rforward_char\\r\\C-xo\\C-@\\A-gg2\\r\\C-u\\A-b\\A-w\\C-xo\\C-y\\C-x\\C-s\\C-x\\C-c"
