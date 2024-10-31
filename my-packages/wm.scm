(define-module (my-packages wm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system haskell)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system perl)
  #:use-module (guix build-system python)
  #:use-module (guix build-system trivial)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages calendar)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages crates-graphics)
  #:use-module (gnu packages datastructures)
  #:use-module (gnu packages docbook)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages haskell-check)
  #:use-module (gnu packages haskell-web)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpd)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages music)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pretty-print)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages sphinx)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages time)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg))
(define-public indicator-sound-switcher
  (package
    (name "indicator-sound-switcher")
    (version "2.3.10.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/yktoo/indicator-sound-switcher")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0y52k56ww2327r7ywwdvld5lx85qmcy8yrpaxc5lim7w3jbf3s85"))))
    (build-system python-build-system)
    (native-inputs (list gettext-minimal gobject-introspection))
    (inputs (list python-pygobject girara python-pulsectl pulseaudio))
    (propagated-inputs (list libappindicator keybinder))
    (arguments
     (list
      #:phases #~(modify-phases %standard-phases
                   (add-before 'install 'patch-xdg-autostart
                     (lambda* (#:key inputs outputs #:allow-other-keys)
                       (let* ((pulseaudio (assoc-ref inputs "pulseaudio"))
                              (pulse (string-append pulseaudio
                                                    "/lib/libpulse.so.0")))
                         (substitute* "setup.py"
                           (("/etc/xdg/autostart")
                            '"share/etc/xdg/autostart"))
                         (substitute* "lib/indicator_sound_switcher/lib_pulseaudio.py"
                           (("libpulse.so.0")
                            pulse))))))))
    (home-page "https://github.com/yktoo/indicator-sound-switcher")
    (synopsis "Sound input/output selector indicator for Linux")
    (description
     "It shows an icon in the indicator area or the system tray
(whatever is available in your desktop environment).
The icon's menu allows you to switch the current sound input and output
(i.e. source ports and sink ports in PulseAudio's terms, respectively) with just two clicks:")
    (license license:gpl3)))
