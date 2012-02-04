-- goto_line 2 RET forward_word forward_word forward_word beginning_of_line a
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "a-g g 2 return a-f a-f a-f c-a a c-x c-s c-x c-c"
