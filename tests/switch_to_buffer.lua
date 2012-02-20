switch_to_buffer "*scratch*"
insert "This is cool!."
switch_to_buffer "switch_to_buffer.input"
insert "This is not."
save_buffer ()
save_buffers_kill_zi ()
