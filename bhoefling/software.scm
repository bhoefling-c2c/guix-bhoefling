;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021 Björn Höfling <bjoern.hoefling@camptocamp.com>
;;;
;;; This file is not part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (bhoefling software)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (ice-9 match)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cpio)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages speech)
  #:use-module (gnu packages package-management))

  (define-public guix-tools
    (let ((commit "66d1f229f12bc8713a9d2927c376a9e91eb7a3d1")
          (revision "10"))
      (package
        (name "guix-tools")
        (version (git-version "0.1.0" revision commit))
        (source (origin
                  (method git-fetch)
                  (uri (git-reference
                        (url "https://gitlab.com/hoebjo/guix-tools.git")
                        (commit commit)))
                  (file-name (git-file-name name version))
                  (sha256
                   (base32
                    "10chig0zjsai7nsii6fz22hll5s0x2yw38iy17bb36y6xpbi5163"))))
        (build-system gnu-build-system)
        (arguments
         `(#:tests?
	   #f
	   #:phases
	   (modify-phases %standard-phases
	     (delete 'configure)
	     (delete 'build)
	     (add-before
		 'install 'subst
	       (lambda* (#:key inputs #:allow-other-keys)
		 (let* ((coreutils (assoc-ref inputs "coreutils"))
		        (tee (string-append coreutils "/bin/tee"))
			(espeak-ng (assoc-ref inputs "espeak-ng"))
			(espeak (string-append espeak-ng "/bin/espeak")))
		   (substitute* '("gbuild")
		     (("tee") tee))
		   (substitute* '("gbuildn")
		     (("espeak") espeak)))))
	     (replace 'install
	       (lambda* (#:key outputs #:allow-other-keys)
		 (let* ((out (assoc-ref outputs "out"))
			(bin (string-append out "/bin")))
		   (install-file "gbuild" bin)
		   (install-file "gbuildn" bin)
		   (install-file "gdev" bin)
		   #t))))))
        (inputs
         `(("coreutils" ,coreutils)
	   ("espeak-ng" ,espeak-ng)))
        (synopsis "Guix build tools")
        (description "Guix build tools are my tiny, personal scripts
 and helpers to build GNU Guix.")
        (home-page "https://gitlab.com/hoebjo/guix-tools")
        (license license:gpl3+))))
