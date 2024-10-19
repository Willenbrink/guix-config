;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2020 pkill-9
;;; Copyright © 2020, 2021 ison <ison@airmail.cc>
;;; Copyright © 2021 pineapples
;;; Copyright © 2021 Jean-Baptiste Volatier <jbv@pm.me>
;;; Copyright © 2021 Kozo <kozodev@runbox.com>
;;; Copyright © 2021, 2022, 2023, 2024 John Kehayias <john.kehayias@protonmail.com>
;;; Copyright © 2023 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2023 Elijah Malaby
;;; Copyright © 2023 Timo Wilken <guix@twilken.net>
;;; Copyright © 2024 Amélia Coutard <contact@ameliathe1st.gay>

(define-module (my-packages game-client)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bittorrent)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages file)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages libbsd)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages lsof)
  #:use-module (nongnu packages nvidia)
  #:use-module (gnu packages openldap)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages photo)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages samba)
  #:use-module (gnu packages scanner)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages toolkits)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages web)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages wine)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (nonguix build-system chromium-binary)
  #:use-module (nonguix multiarch-container)
  #:use-module (nonguix utils))

(define hicolor-icon-theme-lutris
  (package
   (name "hicolor-icon-theme-lutris")
   (version "0.17-ee8fe23c")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/lutris/lutris-runtime")
           (commit "ee8fe23c5bf2ac979efb9c00ca3abbd57af180a8")))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0wjjj46wmnqc8p1hy0q74bpfqf0cm06hd518j170mrm9pnpiil2b"))))
   (build-system copy-build-system)
   (arguments
    (list
     #:install-plan ''(("icons" "share/icons"))))
   (home-page "https://github.com/lutris/lutris-runtime")
   (synopsis "Freedesktop icon theme - Lutris edition")
   (description "Freedesktop icon theme - Lutris edition.")
   (license license:gpl2)))

(define-public lutris
  (package
   (name "lutris")
   (version "0.5.17")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/lutris/lutris/archive/refs/tags/v" version
           ".tar.gz"))
     (sha256
      (base32 "1a0s4s2wf2nmdy7c2axws5q1xg3jnvq6h8ycky1jk36b1g3x04z9"))))
   (build-system copy-build-system)
   (propagated-inputs (list ;Otherwise, TLS doesn't work and it's impossible to connect to itch.io, gog, etc.
                       cairo gsettings-desktop-schemas nss-certs webkitgtk-for-gtk3))
   (inputs (list
            ;; Non-python dependencies:
            file
            gdk-pixbuf
            gnutls
            hicolor-icon-theme-lutris
            hicolor-icon-theme
            libpng
            librsvg
            mesa
            shared-mime-info
            vulkan-loader
            ;; Will be in the path:
            fluidsynth
            glibc
            `(,gtk+ "bin")
            mesa-utils
            p7zip
            pciutils
            procps
            psmisc
            vulkan-tools
            xrandr
            ;; Python dependencies:
            python
            python-dbus
            python-distro
            python-evdev
            python-lxml
            python-pillow
            python-protobuf
            python-pycairo
            python-pygobject
            python-pyyaml
            python-requests
            python-setproctitle))
   (arguments
    (list
     #:phases #~(modify-phases %standard-phases
                               (add-before 'install 'gdk-pixbuf-cache-gen
                                           (lambda* (#:key #:allow-other-keys)
                                             (setenv "GDK_PIXBUF_MODULE_FILE"
                                                     (string-append #$output
                                                                    "/lib/gdk-pixbuf/loaders.cache"))
                                             (mkdir-p (string-append #$output "/lib/gdk-pixbuf"))
                                             (invoke "gdk-pixbuf-query-loaders" "--update-cache"
                                                     #$(file-append librsvg
                                                                    "/lib/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg"))))
                               (add-before 'install 'ldconfig-p
                                           (lambda* (#:key #:allow-other-keys)
                                             (mkdir-p (string-append #$output "/etc"))
                                             (invoke "ldconfig"
                                                     "-C"
                                                     (string-append #$output "/etc/ld.so.cache")
                                                     #$(file-append gnutls "/lib")
                                                     #$(file-append mesa "/lib")
                                                     #$(file-append vulkan-loader "/lib"))
                                             (substitute* "lutris/util/linux.py"
                                                          (("\"-p\"")
                                                           (string-append "\"-C\", \""
                                                                          #$output "/etc/ld.so.cache\", \"-p\"")))))
                               (add-before 'install 'patch-hardcoded-paths-and-wine
                                           (lambda* (#:key #:allow-other-keys)
                                             (substitute* "lutris/util/linux.py"
                                                          (("\"wine\",")
                                                           ""))
                                             (substitute* "lutris/util/graphics/vkquery.py"
                                                          (("libvulkan.so.1")
                                                           #$(file-append vulkan-loader "/lib/libvulkan.so.1")))
                                             (substitute* "lutris/util/magic.py"
                                                          (("libmagic.so.1")
                                                           #$(file-append file "/lib/libmagic.so.1")))
                                             (substitute* "lutris/util/wine/wine.py"
                                                          (("os\\.listdir\\('/usr/lib/'\\)")
                                                           "[]"))))
                               (add-after 'install 'wrap
                                          (lambda* (#:key #:allow-other-keys)
                                            (wrap-program (string-append #$output "/bin/lutris")
                                                          `("GDK_PIXBUF_MODULE_FILE" =
                                                            (,(getenv "GDK_PIXBUF_MODULE_FILE")))
                                                          `("GI_TYPELIB_PATH" =
                                                            (,(getenv "GI_TYPELIB_PATH")))
                                                          `("PATH" =
                                                            ,(list #$(file-append fluidsynth "/bin")
                                                                   #$(file-append glibc "/sbin")
                                                                   (string-append #$gtk+:bin "/bin")
                                                                   #$(file-append mesa-utils "/bin")
                                                                   #$(file-append p7zip "/bin")
                                                                   #$(file-append pciutils "/bin")
                                                                   #$(file-append procps "/bin")
                                                                   #$(file-append psmisc "/bin")
                                                                   #$(file-append vulkan-tools "/bin")
                                                                   #$(file-append xrandr "/bin")
                                                                   #$(file-append xterm "/bin")
                                                                   "$PATH"))
                                                          `("PYTHONPATH" =
                                                            (,(getenv "GUIX_PYTHONPATH")))
                                                          `("XDG_DATA_DIRS" =
                                                            ,(list #$(file-append hicolor-icon-theme-lutris
                                                                                  "/share")
                                                                   #$(file-append hicolor-icon-theme "/share")
                                                                   #$(file-append shared-mime-info "/share")
                                                                   "$XDG_DATA_DIRS"))))))
     #:install-plan ''(("bin" "bin")
                       ("lutris" "lutris")
                       ("share" "share"))))
   (home-page "https://github.com/lutris/lutris")
   (synopsis "Game library manager")
   (description
    "Lutris is a game manager that can be used as a frontend for many sources of games")
   (license license:gpl3)))

(define lutris-client-libs-64 ; For TLS support, to login into itch.io, gog, etc.
  `(("nss-certs" ,nss-certs)
    ("cairo" ,cairo)
    ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
    ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
(define lutris-gameruntime-libs
  `( ;WINE:
    ("alsa-lib" ,alsa-lib)
    ("bash-minimal" ,bash-minimal)
    ;; ("cups" ,cups) ; FIXME
    ("dbus" ,dbus)
    ("eudev" ,eudev)
    ("fontconfig" ,fontconfig)
    ("freetype" ,freetype)
    ("gnutls" ,gnutls)
    ("gst-plugins-base" ,gst-plugins-base)
    ("libgphoto2" ,libgphoto2)
    ("openldap" ,openldap)
    ("samba" ,samba)
    ("sane-backends" ,sane-backends)
    ("libpcap" ,libpcap)
    ("libusb" ,libusb)
    ("libice" ,libice)
    ("libx11" ,libx11)
    ("libxi" ,libxi)
    ("libxext" ,libxext)
    ("libxcursor" ,libxcursor)
    ("libxrender" ,libxrender)
    ("libxrandr" ,libxrandr)
    ("libxinerama" ,libxinerama)
    ("libxxf86vm" ,libxxf86vm)
    ("libxcomposite" ,libxcomposite)
    ("mit-krb5" ,mit-krb5)
    ("openal" ,openal)
    ("pulseaudio" ,pulseaudio)
    ("sdl2" ,sdl2)
    ("unixodbc" ,unixodbc)
    ("v4l-utils" ,v4l-utils)
    ("vkd3d" ,vkd3d)
    ("vulkan-loader" ,vulkan-loader)
    ("coreutils" ,coreutils)
    ;; Deps required for some games:
    ("alsa-plugins:pulseaudio" ,alsa-plugins "pulseaudio")
    ("aria2" ,aria2) ; For the Rockstar launcher
    ("cabextract" ,cabextract) ; For the Rockstar launcher
    ("findutils" ,findutils) ; For the Rockstar launcher
    ("font-dejavu" ,font-dejavu)
    ("font-liberation" ,font-liberation)
    ("gawk" ,gawk) ; For the Rockstar launcher
    ("gcc:lib" ,gcc "lib")
    ("grep" ,grep) ; For the Rockstar launcher
    ("imgui" ,imgui-1.86)
    ("jansson" ,jansson) ; For League of Legends
    ("mangohud" ,mangohud)
    ("mesa" ,mesa)
    ("python" ,python)
    ("sed" ,sed) ; For the Rockstar launcher
    ("xdg-utils" ,xdg-utils) ; For Slay the Princess (and maybe renpy in general).
    ))

(define lutris-fhs-union-64
  (fhs-union `(,@lutris-client-libs-64
               ,@lutris-gameruntime-libs
               ,@fhs-min-libs)
             #:name "fhs-union-64"))
(define lutris-fhs-union-32
  (fhs-union `(,@lutris-gameruntime-libs
               ,@fhs-min-libs)
             #:name "fhs-union-32"
             #:system "i686-linux"))
(define lutris-ld.so.conf
  (packages->ld.so.conf (list lutris-fhs-union-64 lutris-fhs-union-32)))
(define lutris-ld.so.cache
  (ld.so.conf->ld.so.cache lutris-ld.so.conf))

(define lutris-container
  (nonguix-container (name "lutris-wrapped")
                     (wrap-package lutris)
                     (run "/bin/lutris")
                     (modules '(gtk))
                     (packages '(cairo))
                     (ld.so.conf lutris-ld.so.conf)
                     (ld.so.cache lutris-ld.so.cache)
                     (union64 lutris-fhs-union-64)
                     (union32 lutris-fhs-union-32)
                     (description
                      "Lutris is a game manager that can be used as a frontend for many sources of games")))

(define-public lutris-wrapped
  (nonguix-container->package lutris-container))
