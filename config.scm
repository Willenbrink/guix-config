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
 (nongnu packages linux)
 (nongnu system linux-initrd)
 (nongnu packages mozilla)
 (guix utils))
(use-service-modules
 desktop xorg ssh shepherd)
(use-package-modules
 certs bootloaders emacs xorg gnome ssh)

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
 (kernel-arguments (list "console=tty0"))
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

 (swap-devices (list (swap-space (target "/swapfile"))))

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
               (supplementary-groups '("wheel" "audio" "video")))
              %base-user-accounts))

 ;; Globally-installed packages.
 (packages (append (list
                    sway
                    vim emacs
                    fish fd ripgrep git markdown unzip
                    htop
                    gcc-toolchain
                    firefox icedove)
                   %base-packages))

 ;; Add services to the baseline: a DHCP client and
 ;; an SSH server.
 (services (append (modify-services %desktop-services
                                    (gdm-service-type config =>
                                                      (gdm-configuration
                                                       (inherit config)
                                                       (wayland? #t)))
                                    (guix-service-type config =>
                                                       (guix-configuration
                                                        (inherit config)
                                                        (substitute-urls
                                                         (append(list "https://substitutes.nonguix.org")
                                                                %default-substitute-urls))
                                                        (authorized-keys
                                                         (append (list (plain-file "non-guix.pub"
                                                                                   "(public-key
    (ecc (curve Ed25519)
    (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"
                                                                                   ))
                                                                 %default-authorized-guix-keys)))))
                   (list
                    (service xfce-desktop-service-type)

                    (set-xorg-configuration
                     (xorg-configuration
                      (keyboard-layout keyboard-layout)))
                    (service openssh-service-type
                             (openssh-configuration
                              (openssh openssh-sans-x)
                              (port-number 22))))
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
