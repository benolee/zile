-- Regression:
-- crash after accepting an empty argument to insert

-- insert RET
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "a-x i n s e r t return c-g c-x c-s c-x c-c"
