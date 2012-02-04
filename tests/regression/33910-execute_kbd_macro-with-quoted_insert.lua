-- FIXME: Although F1 usually outputs ^[OP, this test will fail
--        when the terminal outputs something else instead.

-- quoted_insert F1 RETURN
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "c-q f1 return c-x c-s c-x c-c"
