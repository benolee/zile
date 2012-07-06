-- describe_key \C-f other_window set_mark goto_line 2 RET copy_region_as_kill
-- other_window yank save_buffer save_buffers_kill_zi
execute_kbd_macro "\\A-xdescribe_key\\r\\C-f\\C-xo\\C-@\\A-gg2\\r\\A-w\\C-xo\\C-y\\C-x\\C-s\\C-x\\C-c"
