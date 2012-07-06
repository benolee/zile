-- set_mark goto_line 3 RET kill_region yank yank open_line
-- goto_line 6 RET yank goto_line 9 RET
execute_kbd_macro "\\C-@\\A-gg3\\r\\C-w\\C-y\\C-y\\C-o\\A-gg6\\r\\C-y\\A-gg9\\r"

-- ESC 3 set_fill_column fill_paragraph ESC _3 goto_line 6 RET
-- ESC 12 set_fill_column fill_paragraph ESC _3 goto_line 2 RET backward_char
-- ESC 33 set_fill_column fill_paragraph save_buffer save_buffers_kill_zi
execute_kbd_macro "\\e3\\C-xf\\A-q\\A-gg6\\r\\e12\\C-xf\\A-q\\A-gg2\\r\\C-b\\e33\\C-xf\\A-q\\C-x\\C-s\\C-x\\C-c"
