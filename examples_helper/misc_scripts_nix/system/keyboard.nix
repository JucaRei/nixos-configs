{pkgs}: ''

  (defalias web (cmd-button "${pkgs.bash}/bin/bash ${pkgs.brave}/bin/brave"))
  (defalias ed (cmd-button "${pkgs.bash}/bin/bash ${pkgs.sublime4}/bin/subl"))

  (defalias prn (cmd-button "echo ${pkgs.brave}/bin/brave >> /tmp/brave.txt"))

  (defsrc
    esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  prnt del
    grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
    tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
    caps a    s    d    f    g    h    j    k    l    ;    '    ret
    lsft z    x    c    v    b    n    m    ,    .    /    rsft up
    lctl lmet lalt           spc            ralt rctl      left down right
  )

  (deflayer qwerty
    esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  prnt del
    grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
    tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
    @cap a    s    d    @f   g    h    @j   k    l    ;    '    ret
    @ls  z    x    c    v    b    n    m    ,    .    /    @rs  up
    lctl lmet lalt          @osl            ralt rctl      left down right
  )

  (defalias cap (tap-next esc lctl))
  (defalias osl (tap-hold-next-release 1000 spc (layer-toggle number)))
  (defalias j (tap-hold-next-release 1000 j (layer-toggle shortcut)))
  (defalias f (tap-hold-next-release 1000 f (layer-toggle shortcut)))
  (defalias ls (sticky-key 1000 lsft))
  (defalias rs (sticky-key 1000 rsft))

  (deflayer number
    esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  prnt del
    grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
    tab  !    @    #    $    %    ^    &    *    \(   \)   \_   +    \
    caps 1    2    3    4    5    6    7    8    9    0    -    =
    lsft z    x    c    v    b    n    m    ,    .    /    rsft up
    lctl lmet lalt           spc            ralt rctl      left down right
  )

  (deflayer shortcut
    esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  prnt del
    grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
    tab  q    w    @ed    r    t    y    u    i    o    p    [    ]    \
    caps a    s    d    f    g    h    j    k    l    ;    '    ret
    lsft z    x    c    v    @web @prn    m    ,    .    /    rsft up
    lctl lmet lalt           spc            ralt rctl      left down right
  )
''
