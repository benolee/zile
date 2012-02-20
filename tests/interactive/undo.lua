-- undo in Emacs undoes everything from the start of the script (cf. fill_paragraph_2.el)

-- delete_char delete_char delete_char delete_char undo undo undo
--  save_buffer save_buffers_kill_zi
execute_kbd_macro "\\C-d\\C-d\\C-d\\C-d\\C-_\\C-_\\C-_\\C-x\\C-s\\C-x\\C-c"
