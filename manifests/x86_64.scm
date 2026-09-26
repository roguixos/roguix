;; What CI builds for x86_64 and publishes on roguix.frolow.dev: the
;; packages of this channel the VPS uses.
(use-modules (guix profiles)
             (roguix packages databases)
             (roguix packages node))

(packages->manifest (list postgresql-17 node-22))
