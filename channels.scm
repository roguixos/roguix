;; The Guix that CI builds with and the VPS runs, so that the binaries CI
;; publishes on roguix.frolow.dev are the ones the VPS asks for: a
;; different commit changes every store path.  Bump it here, let CI
;; rebuild, then `guix pull -C channels.scm` on the VPS.
(list (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (branch "master")
       (commit "230aa373f315f247852ee07dff34146e9b480aec")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
