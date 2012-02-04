-- describe_function "forward_char" RET other_window set_mark goto_line 2 RET
-- universal_argument backward_word copy_region_as_kill other_window yank
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "a-x d e s c r i b e _ f u n c t i o n return f o r w a r d _ c h a r return c-x o c-@ a-g g 2 return c-u a-b a-w c-x o c-y c-x c-s c-x c-c"
