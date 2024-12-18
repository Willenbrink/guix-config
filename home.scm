;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(define-module (home)
  #:use-module (gnu home)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (gnu home services guix)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services pm)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells))

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
   (simple-service 'extra-channels-service
                   home-channels-service-type
                   (list
                    ;; (channel
                    ;;  (name 'nonguix-sewi)
                    ;;  (url "file:///home/sewi/guix/nonguix"))
                    (channel
                     (name 'nonguix)
                     (url "https://gitlab.com/nonguix/nonguix")
                     ;; Enable signature verification:
                     (introduction
                      (make-channel-introduction
                       "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                       (openpgp-fingerprint
                        "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
                    ))
   (service home-dbus-service-type)
   (service home-pipewire-service-type
            (home-pipewire-configuration
             (enable-pulseaudio? #t)))
   (service home-batsignal-service-type
            (home-batsignal-configuration
             (danger-level 5)
             (danger-command "loginctl suspend")))

   (service home-fish-service-type
            (home-fish-configuration
             (environment-variables '(
                                        ;("XDG_CURRENT_DESKTOP" . "sway")
                                      ("EDITOR" . "emacs")))
             (aliases '(("reboot" . "loginctl reboot")
                        ("update" . "sudo echo 'Complete update: Running pull, upgrade, system reconfigure and home reconfigure' && guix pull && guix upgrade && sudo guix system reconfigure ~/guix-config/system.scm && guix home reconfigure ~/guix-config/home.scm")
                        ("cdda-update" . "guix install cataclysm-dda:tiles --with-git-url=cataclysm-dda=https://github.com/CleverRaven/Cataclysm-DDA.git")
                        ("shell" . "guix shell -C -F -N -u sewi coreutils -D ungoogled-chromium fish gcc-toolchain --share=/dev/ --preserve='^DISPLAY\\$' --preserve='^XAUTHORITY\\$' --preserve='^DBUS_.*\\$'  --expose=/var/run/dbus/system_bus_socket --preserve='^XDG_RUNTIME_DIR\\$' --expose=\\$XDG_RUNTIME_DIR/pulse")
                        ))
             ))
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
