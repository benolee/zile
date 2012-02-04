-- set_mark copy_to_register 1 list_registers other_window set_mark
-- goto_line 2 RET copy_region_as_kill other_window yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "c-@ c-x r x 1 a-x l i s t _ r e g i s t e r s return c-x o c-@ a-g g 2 return a-w c-x o c-y c-x c-s c-x c-c"
