;;; diffpdf.el --- Transient diffpdf                 -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Shuguang Sun

;; Author: Shuguang Sun <shuguang79@qq.com>
;; Created: 2021/02/20
;; Version: 1.0
;; URL: https://github.com/ShuguangSun/diffpdf.el
;; Package-Requires: ((emacs "25.1") (transient "0.3.0"))
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Transient UI for diffpdf.

;; Get `diffpdf` for windows from http://soft.rubypdf.com/software/diffpdf.

;;; Code:
(eval-when-compile (require 'subr-x))
(require 'compile)
(require 'transient)

(defgroup diffpdf nil
  "Transient UI for diffpdf."
  :group 'tools
  :prefix "diffpdf")

(defcustom diffpdf-program (executable-find "diffpdf")
  "Program of diffpdf."
  :group 'diffpdf
  :type '(string :tag "Path to diffpdf"))

(defcustom diffpdf-use-compile-p nil
  "If t, using compile to run the command."
  :group 'diffpdf
  :type 'boolean)

(defun diffpdf--choose-files ()
  "Let user choose which files to diff."
  (interactive)
  (completing-read-multiple "Select pdf file(s): "
                            #'read-file-name-internal nil t))

(defun diffpdf--command (&optional args)
  "Invoke the compile mode with the run command and ARGS if provided."
  (interactive (list (diffpdf-arguments)))
  (save-excursion
    (let* ((arguments (string-join args " "))
           (files (diffpdf--choose-files))
           (m (safe-length files))
           command)
      (setq command
            (concat diffpdf-program " " arguments " \""
                    (if (> m 2)
                        (string-join (nbutlast files (- m 2)) "\" \"")
                      (string-join files "\" \""))
                    "\""))
      (if diffpdf-use-compile-p
          (progn
            (setq compilation-read-command t)
            (setq compile-command command)
            (call-interactively #'compile))
        (async-shell-command command)))))


(defun diffpdf-dired--command (&optional args)
  "Invoke the compile mode with the run command and ARGS if provided."
  (interactive (list (diffpdf-arguments)))
  (save-excursion
    (let* ((arguments (string-join args " "))
           (files (dired-get-marked-files))
           (m (safe-length files))
           command)
      (setq command
            (concat diffpdf-program " " arguments " \""
                    (if (> m 2)
                        (string-join (nbutlast files (- m 2)) "\" \"")
                      (string-join files "\" \""))
                    "\""))
      (if diffpdf-use-compile-p
          (progn
            (setq compilation-read-command t)
            (setq compile-command command)
            (call-interactively #'compile))
        (async-shell-command command)))))

;;;###autoload
(defun diffpdf ()
  "Entrypoint function to the package.
Just for autoload."
  (interactive)
  (call-interactively #'diffpdf-menu))

;; Transient menus
(transient-define-prefix diffpdf-menu ()
  "Open diffpdf transient menu pop up."
    ["Arguments"
     ("-a" "set the initial comparison mode to Appearance"  "--appearance")
     ("-c" "set the initial comparison mode to Characters"  "--characters")
     ("-w" "set the initial comparison mode to Words"       "--words")]
    [["Command"
      ("d" "run diffpdf"       diffpdf--command)
      ("D" "run diffpdf from dired"       diffpdf-dired--command)]]
  (interactive)
  (transient-setup 'diffpdf-menu))

(defun diffpdf-arguments nil
  "Arguments function for transient."
  (transient-args 'diffpdf))


(provide 'diffpdf)
;;; diffpdf.el ends here
