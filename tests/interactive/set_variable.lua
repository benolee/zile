-- set_variable "kill_whole_line" RET t RET
-- kill_line save_buffer save_buffers_kill_zi
execute_kbd_macro "a-x s e t _ v a r i a b l e return k i l l _ w h o l e _ l i n e return t return c-k c-x c-s c-x c-c"
