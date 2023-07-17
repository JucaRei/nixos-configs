# The GNU build system. Commonly used for projects at GNU and anyone who wants
# to be a GNU fanatic.
#
# It's a good thing they have documented the full details in one of their
# manuals at
# https://www.gnu.org/software/automake/manual/html_node/GNU-Build-System.html
{ mkShell
, autoconf
, autoconf-archive
, automake
, gcc
, gettext
, coreutils
, pkg-config
, help2man
, texinfo
,
}:
mkShell {
  packages = [
    autoconf
    autoconf-archive
    automake
    coreutils
    gettext
    gcc
    help2man
    texinfo
    pkg-config
  ];

  inputsFrom = [ gcc ];
}
