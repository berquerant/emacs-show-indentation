# emacs-show-indentation

Show indentation depth in the margin.

## Usage

Show indentation:

``` emacs-lisp
(show-indentation-show)
```

Cleanup the left margin:

``` emacs-lisp
(show-indentation-cleanup)
```

Enable only for the current buffer:

``` emacs-lisp
;; for CUI
(show-indentation-show-idle-timer-mode)
```

Enable globally:

``` emacs-lisp
;; for CUI
(global-show-indentation-show-idle-timer-mode)
;; for GUI
(show-indentation-global-toggle)
```

## Customize

### show-indentation-margin-width

Width of the margin.

### show-indentation-include-buffer-regexp

Regexp for buffer names to display indentation.

### show-indentation-exclude-buffer-regexp

Regexp for buffer names to exclude from indentation display.

### show-indentation-minor-mode-delay

Number of seconds to show indentation.
