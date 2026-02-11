# emacs-show-indentation

Show indentation depth in the margin.

## Usage

Enable only for the current buffer:

``` emacs-lisp
(show-indentation-show-idle-timer-mode)
```

Enable globally:

``` emacs-lisp
(global-show-indentation-show-idle-timer-mode)
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
