;;; show-indentation.el --- show indentation depth in the margin -*- lexical-binding: t -*-

;; Author: berquerant
;; Maintainer: berquerant
;; Created: 4 Feb 2026
;; Version: 0.1.0
;; Keywords: indentation
;; URL: https://github.com/berquerant/emacs-show-indenttion

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;; Code:

(defgroup show-indentation nil
  "Show indentation depth in the margin."
  :group 'show-indentation
  :prefix "show-indentation-")

(defcustom show-indentation-margin-width 3
  "Width of the margin."
  :type 'integer)

(defcustom show-indentation-include-buffer-regexp "\\*scratch\\*"
  "Regexp for buffer names to display indentation."
  :type 'string)

(defcustom show-indentation-exclude-buffer-regexp "0^"
  "Regexp for buffer names to exclude from indentation display."
  :type 'string)

(defun show-indentation--show ()
  "Show `current-indentation' in the left margin."
  (set-window-margins (selected-window) show-indentation-margin-width)
  (remove-overlays (point-min) (point-max) 'type 'margin-indent)
  (save-excursion
    (goto-char (window-start))
    (while (< (point) (window-end))
      (let* ((value (current-indentation))
             (ov (make-overlay (line-beginning-position) (line-beginning-position))))
        (overlay-put ov 'before-string
                     (propertize
                      " "
                      'display
                      `((margin left-margin)
                        ,(format (format "%%%dd" show-indentation-margin-width) value))))
        (overlay-put ov 'type 'margin-indent)
        (forward-line 1)))))

;;;###autoload
(defun show-indentation-show ()
  "Show `current-indentation' in the left margin."
  (interactive)
  (show-indentation--show))

(defun show-indentation--disable-cleanup ()
  (set-window-margins (selected-window) 0)
  (remove-overlays (point-min) (point-max) 'type 'margin-indent))

(defun show-indentation--enable-setup ()
  (show-indentation--show))

(defun show-indentation--disable ()
  (remove-hook 'post-command-hook 'show-indentation--show t)
  (show-indentation--disable-cleanup))

(defun show-indentation--enable ()
  (add-hook 'post-command-hook 'show-indentation--show nil t)
  (show-indentation--enable-setup))

(defun show-indentation--enabled? ()
  (member 'show-indentation--show post-command-hook))

;;;###autoload
(defun show-indentation-toggle ()
  "If `show-indentation--show' is not in `post-command-hook', add it.
Otherwise, remove it."
  (interactive)
  (if (show-indentation--enabled?) (show-indentation--disable)
    (show-indentation--enable)))

(defun show-indentation--global-should-show? ()
  (or (string-match show-indentation-include-buffer-regexp (buffer-name))
      (and (not (string-match show-indentation-exclude-buffer-regexp (buffer-name)))
           (buffer-file-name))))

(defun show-indentation--global-show ()
  (when (show-indentation--global-should-show?)
    (show-indentation--show)))

(defun show-indentation--global-enabled? ()
  (member 'show-indentation--global-show (default-value 'post-command-hook)))

(defun show-indentation--global-disable ()
  (remove-hook 'post-command-hook 'show-indentation--global-show)
  (show-indentation--disable-cleanup))

(defun show-indentation--global-enable ()
  (add-hook 'post-command-hook 'show-indentation--global-show)
  (show-indentation--enable-setup))

;;;###autoload
(defun show-indentation-global-toggle ()
  "If `show-indentation--global-show' is not in `post-command-hook', add it.
Otherwise, remove it."
  (interactive)
  (if (show-indentation--global-enabled?) (show-indentation--global-disable)
    (show-indentation--global-enable)))

(provide 'show-indentation)
;;; show-indentation.el ends here
