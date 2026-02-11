;;; show-indentation.el --- show indentation depth in the margin -*- lexical-binding: t -*-

;; Author: berquerant
;; Maintainer: berquerant
;; Created: 4 Feb 2026
;; Version: 0.2.1
;; Package-Requires: ((idle-timer "v0.1.0"))
;; Keywords: indentation
;; URL: https://github.com/berquerant/emacs-show-indentation

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

;; https://github.com/berquerant/emacs-idle-timer
(require 'idle-timer)

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

(defcustom show-indentation-minor-mode-delay 1
  "Number of seconds to show indentation."
  :type 'integer)

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

(defun show-indentation--cleanup ()
  (set-window-margins (selected-window) 0)
  (remove-overlays (point-min) (point-max) 'type 'margin-indent))

;;;###autoload
(defun show-indentation-cleanup ()
  "Cleanup `show-indentation-show'."
  (interactive)
  (show-indentation--cleanup))

;; FIXME: This timer-based overlay update causes Emacs GUI to hang.
;; - Works fine in TTY (CUI) mode, but freezes in GUI mode.
;; - Potential causes:
;;   1. Infinite redisplay loop triggered by `set-window-margins` or margin overlays.
;;   2. Conflict between `window-end` calculation and GUI font rendering.
;;   3. Deadlock in the rendering engine when updating `display` properties in the margin.
(idle-timer-define-minor-mode show-indentation-show show-indentation-minor-mode-delay)

(defun show-indentation-show-idle-timer-mode-toggle--disabled-hook ()
  (unless show-indentation-show-idle-timer-mode
    (show-indentation--cleanup)
    (remove-hook 'show-indentation-show-idle-timer-mode-hook
                 'show-indentation-show-idle-timer-mode-toggle--disabled-hook t)))

(defun show-indentation-show-idle-timer-mode--hook ()
  (when show-indentation-show-idle-timer-mode
    (add-hook 'show-indentation-show-idle-timer-mode-hook
              'show-indentation-show-idle-timer-mode-toggle--disabled-hook nil t)))

(add-hook 'show-indentation-show-idle-timer-mode-hook 'show-indentation-show-idle-timer-mode--hook)

(defun show-indentation--should-show? ()
  (and (not (minibufferp))
       (or (string-match show-indentation-include-buffer-regexp (buffer-name))
           (and (not (string-match show-indentation-exclude-buffer-regexp (buffer-name)))
                (buffer-file-name)))))

(defun show-indentation-show-idle-timer-mode--should-turn-on? ()
  (show-indentation--should-show?))

(defun show-indentation-show-idle-timer-mode-turn-on ()
  (when (show-indentation-show-idle-timer-mode--should-turn-on?)
      (show-indentation-show-idle-timer-mode t)))

(define-globalized-minor-mode global-show-indentation-show-idle-timer-mode
  show-indentation-show-idle-timer-mode
  show-indentation-show-idle-timer-mode-turn-on)

(defun show-indentation--global-show ()
  (when (show-indentation--should-show?)
    (show-indentation--show)))

(defun show-indentation--global-enabled? ()
  (member 'show-indentation--global-show (default-value 'post-command-hook)))

(defun show-indentation--global-disable ()
  (remove-hook 'post-command-hook 'show-indentation--global-show)
  (show-indentation--cleanup))

(defun show-indentation--global-enable ()
  (add-hook 'post-command-hook 'show-indentation--global-show))

;;;###autoload
(defun show-indentation-global-toggle ()
  "If `show-indentation--global-show' is not in `post-command-hook', add it.
Otherwise, remove it."
  (interactive)
  (if (show-indentation--global-enabled?) (show-indentation--global-disable)
    (show-indentation--global-enable)))

(provide 'show-indentation)
;;; show-indentation.el ends here
