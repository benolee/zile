; ESC 4 forward-char set-mark end-of-buffer
; exchange-point-and-mark f save-buffer save-buffers-kill-emacs
(execute-kbd-macro "\e4\C-f\C-@\M->\C-x\C-xf\C-x\C-s\C-x\C-c")

;; With a direct translation, Emacs exits 255 with 'end of buffer' error
;; for some reason?!
;(execute-kbd-macro "\e4\C-f\C-@\C-n\C-n\C-x\C-xf\C-x\C-s\C-x\C-c")
