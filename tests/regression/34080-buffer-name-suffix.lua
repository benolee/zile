-- Regression:
-- crash when creating suffixed buffers for files with the same name

-- find_file a/f RET find_file b/f RET kill_buffer RET kill_buffer RET
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "c-x c-f a / f return c-x c-f b / f return c-x k return c-x k return c-x c-s c-x c-c"
