-- set_mark goto_line 3 RET kill_region yank yank open_line
-- goto_line 6 RET yank goto_line 9 RET
execute_kbd_macro "c-@ a-g g 3 return c-w c-y c-y c-o a-g g 6 return c-y a-g g 9 return"

-- ESC 3 set_fill_column fill_paragraph ESC _3 goto_line 6 RET
-- ESC 12 set_fill_column fill_paragraph ESC _3 goto_line 2 RET backward_char
-- ESC 33 set_fill_column fill_paragraph save_buffer save_buffers_kill_zi
execute_kbd_macro "escape 3 c-x f a-q a-g g 6 return escape 1 2 c-x f a-q a-g g 2 return c-b escape 3 3 c-x f a-q c-x c-s c-x c-c"
