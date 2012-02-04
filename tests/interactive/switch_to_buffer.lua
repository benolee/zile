-- switch_to_buffer "testbuf" RET "get this" RET switch_to_buffer RET
execute_kbd_macro "c-x b t e s t b u f return g e t space t h i s return c-x b return"

-- switch_to_buffer "testb" TAB RET "leave this" RET goto_line 1 RET kill_line kill_line
-- switch_to_buffer RET yank save_buffer save_buffers_kill_zi
execute_kbd_macro "c-x b t e s t b tab return l e a v e space t h i s return a-g g 1 return c-k c-k c-x b return c-y c-x c-s c-x c-c"
