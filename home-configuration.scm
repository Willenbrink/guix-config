;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules
 (gnu home)
 (gnu packages)
 (gnu services)
 (guix gexp)
 (gnu home services shepherd)
 (gnu home services sound)
 (gnu home services desktop)
 (gnu home services shells))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages (specifications->packages (list
                                      "opam"
                                      "gst-plugins-bad"
                                      "xkeyboard-config"
                                      "xdot"
                                      "nextcloud-client"
                                      "steam"
                                      "shellcheck" "emacs-nerd-icons" "make"
                                      )))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 ;; (define mpd-service-type
 ;;   (service-type
 ;;    (name 'mpd)
 ;;    (extensions (list (service-extension home-shepherd-service-type )))))

 ;; (service
 ;;  'mpd
 ;;  #:requirement '(home-shepherd-service-type)
 ;;  #:respawn? #t
 ;;  #:start (make)
 ;;  #:stop (make-kill-destructor ))

 (services
  (list
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (services (list
                        (shepherd-service
                         (provision '(mpd))
                         (start #~(make-forkexec-constructor '("mpd" "--no-daemon")))
                         (stop #~(make-kill-destructor))
                         (documentation "Serve music even without a player running."))
                        ))))
   ;; (service mpd-service-type)
   (service home-dbus-service-type)
   (service home-pipewire-service-type
            (home-pipewire-configuration
             (enable-pulseaudio? #t)))
   (service home-fish-service-type)
   (service home-bash-service-type
            (home-bash-configuration
             (aliases '(("grep" . "grep --color=auto")
                        ("ip" . "ip -color=auto")
                        ("ll" . "ls -l")
                        ("ls" . "ls -p --color=auto")))
             (bashrc (list (local-file ".bashrc" "bashrc")))
             (bash-profile (list (local-file ".bash_profile"
                                             "bash_profile")))))
   )))
