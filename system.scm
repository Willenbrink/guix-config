(use-modules
 (gnu)
 (gnu system nss)
 (gnu packages shells)
 (gnu packages wm)
 (gnu packages admin)
 (gnu packages vim)
 (gnu packages rust-apps)
 (gnu packages version-control)
 (gnu packages markup)
 (gnu packages compression)
 (gnu packages commencement)
 (gnu packages gnuzilla)
 (gnu packages suckless)
 (gnu packages xdisorg)
 (gnu packages libusb)
 (gnu packages nfs)
 (gnu packages networking)
 (gnu packages linux)
 (gnu system setuid)
 (gnu services guix)

 (gnu services)
 (gnu services authentication)
 (gnu services shepherd)
 (gnu services base)
 (gnu services configuration)
 (gnu services dbus)
 (gnu services avahi)
 (gnu services xorg)
 (gnu services networking)
 (gnu services pm)
 (gnu services sound)
 ((gnu system file-systems)
  #:select (%control-groups
            %elogind-file-systems
            file-system))
 (gnu system)
 (gnu system setuid)
 (gnu system shadow)
 (gnu system uuid)
 (gnu system pam)
 (gnu packages glib)
 (gnu packages admin)
 (gnu packages cups)
 (gnu packages freedesktop)
 (gnu packages gnome)
 (gnu packages kde)
 (gnu packages kde-frameworks)
 (gnu packages kde-plasma)
 (gnu packages pulseaudio)
 (gnu packages xfce)
 (gnu packages avahi)
 (gnu packages xdisorg)
 (gnu packages scanner)
 (gnu packages suckless)
 (gnu packages sugar)
 (gnu packages linux)
 (gnu packages libusb)
 (gnu packages nfs)
 (gnu packages package-management)
 (guix channels)

 (nongnu packages linux)
 (nongnu system linux-initrd)
 (nongnu packages mozilla)

 ;; (home-configuration)

 (guix utils))


(use-service-modules
 desktop xorg ssh shepherd)
(use-package-modules
 certs bootloaders emacs xorg gnome ssh)

(define my-channels
  (append
   (list
    ;; (channel
    ;;  (name 'my-packages)
    ;;  (url "file:///home/sewi/guix-config/")
    ;;  (branch "master"))
    ;; (channel
    ;;  (name 'nonguix-local)
    ;;  (url "file:///home/sewi/guix/nonguix"))
    (channel
     (name 'nonguix)
     (url "https://gitlab.com/nonguix/nonguix")
     ;; Enable signature verification:
     (introduction
      (make-channel-introduction
       "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
       (openpgp-fingerprint
        "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
   %default-channels))

(operating-system
 (host-name "framework-guix")
 (timezone "Europe/Berlin")
 (locale "en_US.utf8")
 (keyboard-layout (keyboard-layout "de"))

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets '("/boot/efi"))
              (keyboard-layout keyboard-layout)))

 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 ;; It's fitting to support the equally bare bones ‘-nographic’
 ;; QEMU option, which also nicely sidesteps forcing QWERTY.
 (kernel-arguments (append
                    (list "console=tty0"
                          "resume=/dev/nvme0n1p3"
                          "resume_offset=38176768")
                    %default-kernel-arguments))
 (file-systems (append
                (list (file-system
                       (device (uuid "fd1c49b1-761e-44e4-b99e-040d626df883"))
                       (mount-point "/")
                       (type "ext4"))
                      (file-system
                       (device (uuid "D73B-46BC" 'fat))
                       (mount-point "/boot/efi")
                       (type "vfat")))
                %base-file-systems))

 (swap-devices (list
                (swap-space
                 (target "/swapfile")
                 (dependencies (filter (file-system-mount-point-predicate "/") file-systems))
                 (discard? #t))))

 ;; This is where user accounts are specified.  The "root"
 ;; account is implicit, and is initially created with the
 ;; empty password.
 (users (cons (user-account
               (name "sewi")
               (group "users")
               (shell (file-append fish "/bin/fish"))

               ;; Adding the account to the "wheel" group
               ;; makes it a sudoer.  Adding it to "audio"
               ;; and "video" allows the user to play sound
               ;; and access the webcam.
               (supplementary-groups '("users"
                                       "wheel"
                                       "disk"
                                       "audio"
                                       "video"
                                       "netdev"
                                       "kvm"
                                       ;; "docker"
                                       ;; "libvirt"
                                       )))
              %base-user-accounts))

 ;; Globally-installed packages.
 (packages (append (list
                    sway
                    vim emacs
                    fish fd ripgrep git markdown unzip
                    htop
                    gcc-toolchain
                    firefox)
                   %base-packages))

 ;; Add services to the baseline: a DHCP client and
 ;; an SSH server.
 (services
  (append
   (modify-services %desktop-services
                    (elogind-service-type
                     config => (elogind-configuration
                                (inherit config)
                                (hibernate-delay-seconds 43210))) ; 12h
                    (guix-service-type
                     config => (guix-configuration
                                (inherit config)
                                ;; (channels my-channels)
                                ;; (guix (guix-for-channels my-channels))
                                (substitute-urls
                                 (append (list "https://substitutes.nonguix.org")
                                         %default-substitute-urls))
                                (authorized-keys
                                 (append (list (plain-file "non-guix.pub"
                                                           "(public-key
    (ecc (curve Ed25519)
    (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"
                                                           ))
                                         %default-authorized-guix-keys))))
                    (gdm-service-type config =>
                                      (gdm-configuration
                                       (inherit config)
                                       (wayland? #t)))
                    (wpa-supplicant-service-type config =>
                                                 (wpa-supplicant-configuration
                                                  (inherit config)
                                                  (config-file "/home/sewi/.config/cat_installer/cat_installer.conf")))    ;needed by NetworkManager
                    )
   (list
    (service gnome-keyring-service-type
             (gnome-keyring-configuration
              ;; (pam-services
              ;;  '(
              ;;    ("gdm-password" . "login")
              ;;    ("passwd" . "passwd")
              ;;    ))
              ))
    (service bluetooth-service-type
             (bluetooth-configuration
              (auto-enable? #t)))
    (simple-service 'blueman dbus-root-service-type (list blueman))
    (service thermald-service-type)
    ;; Either tlp or ppd
    (service tlp-service-type
             (tlp-configuration
              (sched-powersave-on-bat? #f)
                                        ;Unsure what this does
              ;; (runtime-pm-on-bat "auto")
              (restore-device-state-on-startup? #t)))
    ;; (service power-profiles-daemon-service-type)
                                        ;(service fprintd-service-type)


    (service xfce-desktop-service-type)
    (service gnome-desktop-service-type)
    (service plasma-desktop-service-type)

    (set-xorg-configuration
     (xorg-configuration
      (keyboard-layout keyboard-layout)))
    (service openssh-service-type
             (openssh-configuration
              (openssh openssh-sans-x)
              (port-number 22)))
	(service pam-limits-service-type
		     ;; For Lutris / Wine esync
			 (list (pam-limits-entry "*" 'hard 'nofile 524288)))
    ;; (service guix-home-service-type `(("sewi" ,sewi-home-config)))
    )
   ))

 ;; (essential-services
 ;;  (modify-services (operating-system-default-essential-services
 ;;                    this-operating-system)
 ;;                   (shepherd-root-service-type
 ;;                    config =>
 ;;                    (shepherd-configuration
 ;;                     (inherit config)
 ;;                     (shepherd (@ (shepherd-package) shepherd))))))

 (name-service-switch %mdns-host-lookup-nss))
