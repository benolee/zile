-- search_forward "ra" isearch_forward RET 2 isearch_forward isearch_forward RET 3
-- save_buffer save_buffers_kill_zi
isearch_nonincremental_instead = false
execute_kbd_macro "c-s r a c-s return 2 c-s c-s return 3 c-x c-s c-x c-c"
