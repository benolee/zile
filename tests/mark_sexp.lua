forward_word ()
insert "("
forward_word (3)
insert ")"
backward_word (2)
backward_char (5)
mark_sexp ()
kill_region (point, mark)
save_buffer ()
save_buffers_kill_zi ()