;;; Node.js newer than Guix's.

(define-module (roguix packages node)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (gnu packages node)
  #:export (node-22))

;; Guix stops at 22.14.  earn-money-bot needs 22.16 (node:sqlite's
;; backup()) and says 22.18, which also strips TypeScript types without a
;; flag.  Guix's node builds against Guix's libuv, llhttp, ICU, nghttp2 and
;; c-ares, which this release has outgrown (it wants ICU 78, libuv 1.51...);
;; this one keeps the copies bundled in the tarball instead.  Tests are
;; off: their deletions and patches in node-lts follow 22.14's tree.
(define node-22
  (package
    (inherit node-lts)
    (version "22.23.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://nodejs.org/dist/v" version
                                  "/node-v" version ".tar.gz"))
              (sha256
               (base32
                "16krv4h75a2ak6s99jswcq67k7pikdibvf7m74yk12a850dwhdll"))))
    (arguments
     (substitute-keyword-arguments (package-arguments node-lts)
       ((#:configure-flags _)
        ;; Needed for correct snapshot checksums, as in node-lts.
        ''("--v8-enable-snapshot-compression"))
       ((#:tests? _ #f) #f)
       ((#:phases phases)
        `(modify-phases ,phases
           ;; These point node-lts's host tools at Guix's libraries and
           ;; replace its bundled llhttp.
           (delete 'set-bootstrap-host-rpath)
           (delete 'replace-llhttp-sources)
           (delete 'patch-additional-hardcoded-program-references)
           (delete 'delete-problematic-tests)
           (delete 'patch-problematic-tests)
           ;; node-lts's reason stands, but npm's tar moved write-entry.js
           ;; to dist/{commonjs,esm}.
           (replace 'ignore-number-of-hardlinks
             (lambda* (#:key outputs #:allow-other-keys)
               (substitute*
                   (find-files (string-append (assoc-ref outputs "out")
                                              "/lib/node_modules/npm"
                                              "/node_modules/tar/dist")
                               "^write-entry\\.js$")
                 (("this.stat.nlink > 1") "false"))))))))))
