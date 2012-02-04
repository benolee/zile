-- undo in Emacs undoes everything from the start of the script (cf. fill_paragraph_2.el)

-- delete_char delete_char delete_char delete_char undo undo undo
--  save_buffer save_buffers_kill_zi
execute_kbd_macro "c-d c-d c-d c-d c-_ c-_ c-_ c-x c-s c-x c-c"
