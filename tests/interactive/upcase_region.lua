-- By default interactive upcase_region is disabled in GNU Emacs.

-- set_mark goto_line 3 RET upcase_region
-- save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-@\\M-gg3\\r\\C-x\\C-u\\C-x\\C-s\\C-x\\C-c"
