;;; Databases Guix does not have yet.

(define-module (roguix packages databases)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages flex)
  #:export (postgresql-17))

;; Guix stops at 16.  The VPS ran 17 on Debian: staying on 17 keeps its
;; dumps loadable as they are (psql 16 rejects \restrict and
;; transaction_timeout in them).
(define postgresql-17
  (package
    (inherit postgresql-16)
    (version "17.11")
    (source (origin
              (inherit (package-source postgresql-16))
              (uri (string-append "https://ftp.postgresql.org/pub/source/v"
                                  version "/postgresql-" version ".tar.bz2"))
              (sha256
               (base32
                "0y99shi069p6fkr0ay1llqra0sdz8899091km8afswwyqnrz49yx"))))
    (arguments
     (substitute-keyword-arguments (package-arguments postgresql-16)
       ((#:phases phases)
        ;; Since 17 the tarball has no prebuilt manuals, and building them
        ;; needs the DocBook XSL toolchain; a server needs neither.
        #~(modify-phases #$phases
            (delete 'install-manuals)))))
    ;; Since 17 the tarball has no generated parsers and scanners either.
    (native-inputs (modify-inputs (package-native-inputs postgresql-16)
                     (prepend bison flex)))))
