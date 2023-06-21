I use separate Firefox profiles for work and personal stuff. To distinguish those I place them on different workspaces.

- Workspace 0: `firefox --no-remote -P MyJob`
- Workspace 1: `firefox --no-remote -P default`

I have also company Slack on Workspace 0. Which usually contains links to some work stuff.

The problem
====

When I open a link in Slack, it opens a new tab in Firefox at Workspace 1. But I want it to open in Firefox at Workspace 0!

In general, I want it to open links in current workspace. The algorithm which FF uses to determine which window to open new tab in, is bad.

The reason
====
Slack opens link with `xdg-open`. So I have to fix `xdg-open` to make Slack links work. The `xdg-open` uses `gio` tool, which detects MIME type of an argument and uses default application for that MIME type. The MIME mappings stay in `~/.config/mimeapps.list` config file.

```
$ grep https ~/.config/mimeapps.list 
x-scheme-handler/https=firefox.desktop
x-scheme-handler/https=org.gnome.Epiphany.desktop;firefox.desktop
```
So in my case `xdg-open https://google.com` fires `firefox.desktop` with `https://google.com` argument. The mentioned desktop icon looks like this (I use NixOS distro):
```
$ cat /home/danbst/.nix-profile/share/applications/firefox.desktop
[Desktop Entry]
Type=Application
Exec=firefox %U    # <----
Terminal=false
Name=Firefox
Categories=Application;Network;WebBrowser;
Icon=firefox
Comment=
GenericName=Web Browser
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp
```
I've highlighted the `Exec` line, which searches `$PATH` envvar for a given executable.

In the end, when I click a link in Slack, it runs a command `firefox https://...`, which opens a new tab in a window with default profile. When no default profile found or all windows are opened with default profile, it uses previously focused Firefox window. So if you did some Facebook lurk on Workspace 1, and then suddenly react to Slack message (on Workspace 0) and click a link, it will open URL in Firefox Workspace 1.

The solution
====
We have to create a wrapper around firefox, which should detect current workspace, find Firefox there, focus it and open a new tab. We also have to create a `.desktop` file, which will run this wrapper and set it as default.

I'm attaching the wrapper script and Nix-script to build this mini-package. After installing into current profile with `nix-env -if .`, you should reload Gnome Shell (Alt-F2 r Enter) and change things in `~/.config/mimeapps.list`:

```
$ grep http ~/.config/mimeapps.list 
x-scheme-handler/http=UrlLauncher.desktop
x-scheme-handler/https=UrlLauncher.desktop
x-scheme-handler/https=org.gnome.Epiphany.desktop;firefox.desktop;UrlLauncher.desktop
```

Now `xdg-open https://google.com` will use `url-launcher` tool to open links.

NOTE: if you want to use this script outside NixOS, you should have `xdotool` and `wmctrl` tools installed.