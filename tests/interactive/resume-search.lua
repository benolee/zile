-- search_forward "ra" isearch_forward RET 2 isearch_forward isearch_forward RET 3
-- save_buffer save_buffers_kill_zi
(set_variable "isearch_nonincremental_instead" false)
(execute_kbd_macro "\C-sra\C-s\r2\C-s\C-s\r3\C-x\C-s\C-x\C-c")
