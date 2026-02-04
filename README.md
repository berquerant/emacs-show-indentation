# emacs-show-indentation

Show indentation depth in the margin.

## Usage

Enable only for the current buffer:

``` emacs-lisp
(show-indentation-toggle)
```

Enable globally:

``` emacs-lisp
(show-indentation-global-toggle)
```

## Customize

### show-indentation-margin-width

Width of the margin.

### show-indentation-include-buffer-regexp

Regexp for buffer names to display indentation.

### show-indentation-exclude-buffer-regexp

Regexp for buffer names to exclude from indentation display.
