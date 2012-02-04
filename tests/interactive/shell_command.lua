-- shell_command "echo foo" RET save_buffer save_buffers_kill_zi
execute_kbd_macro "c-u a-! e c h o space f o o return c-x c-s c-x c-c"
