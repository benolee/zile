-- set_mark copy_to_register 1 list_registers other_window set_mark
-- goto_line 2 RET copy_region_as_kill other_window yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-@\\C-xrx1\\M-xlist_registers\\r\\C-xo\\C-@\\M-gg2\\r\\M-w\\C-xo\\C-y\\C-x\\C-s\\C-x\\C-c"
