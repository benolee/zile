-- ESC 1 ESC ! "echo foo" \A-x RET
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "a-1 a-! e c h o space f o o a-x return c-x c-s c-x c-c"
