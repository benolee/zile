-- describe_variable "tab_width" RET other_window set_mark goto_line 2 RET
-- universal_argument backward_word copy_region_as_kill other_window yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\M-xdescribe_variable\\rtab_width\\r\\C-xo\\C-@\\M-gg2\\r\\C-u\\M-b\\M-w\\C-xo\\C-y\\C-x\\C-s\\C-x\\C-c"
