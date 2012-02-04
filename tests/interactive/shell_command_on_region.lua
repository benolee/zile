-- set_mark goto_line 5 RET shell_command_on_region "sort" RET
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "c-@ a-g g 5 return c-u a-| s o r t return c-x c-s c-x c-c"
