call_command ("list-buffers")
call_command ("other-window", "1")
call_command ("set-mark", "point")
call_command ("forward-line")
call_command ("copy-region-as-kill", "point", "mark")
call_command ("other-window", "-1")
call_command ("yank")
call_command ("save-buffer")
call_command ("save-buffers-kill-emacs")
