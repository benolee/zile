-- describe-function "forward-char" RET other-window set-mark goto-line 2 RET
-- universal-argument backward-word copy-region-as-kill other-window yank
-- save-buffer save-buffers-kill-emacs
call_command ("execute-kbd-macro", "\\M-xdescribe-function\\rforward-char\\r\\C-xo\\C-@\\M-gg2\\r\\C-u\\M-b\\M-w\\C-xo\\C-y\\C-x\\C-s\\C-x\\C-c")
