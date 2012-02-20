-- switch_to_buffer "testbuf" RET "get this" RET switch_to_buffer RET
execute_kbd_macro "\\C-xbtestbuf\\rget this\\r\\C-xb\\r"

-- switch_to_buffer "testb" TAB RET "leave this" RET goto_line 1 RET kill_line kill_line
-- switch_to_buffer RET yank save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-xbtestb	\\rleave this\\r\\M-gg1\\r\\C-k\\C-k\\C-xb\\r\\C-y\\C-x\\C-s\\C-x\\C-c"
