# ## How to rebind keys in Firefox in NixOS
{ pkgs, ... }: {
  home-manager.users.youruser = {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        extraPrefs = ''
          try {
            let { classes: Cc, interfaces: Ci, manager: Cm  } = Components;
            const {Services} = Components.utils.import("resource://gre/modules/Services.jsm");
            function ConfigJS() { Services.obs.addObserver(this, "chrome-document-global-created", false); }
            ConfigJS.prototype = {
              observe: function (aSubject) { aSubject.addEventListener("DOMContentLoaded", this, {once: true}); },
              handleEvent: function (aEvent) {
                let document = aEvent.originalTarget; let window = document.defaultView; let location = window.location;

                if (/^(chrome:(?!\/\/(global\/content\/commonDialog|browser\/content\/webext-panels)\.x?html)|about:(?!blank))/i.test(location.href)) {
                  if (window._gBrowser) {
                    // Rewrite keyboard shortcuts. Rules:
                    // 1. Can't create own 'command' elements
                    // 2. Modify existing elements
                    // 3. Search elements for changes:
                    //    By key: https://searchfox.org/mozilla-central/search?q=%3Ckey+id%3D&path=&case=false&regexp=false
                    //       Ids of keys: https://searchfox.org/mozilla-central/source/browser/locales/en-US/browser/browserSets.ftl
                    //    By command: https://searchfox.org/mozilla-central/search?q=%5Cbcommand%3D%22&path=browser%2F&case=false&regexp=true

                    // Selecting tabs
                    /// Prev: Ctrl-H
                    window.document.getElementById("key_gotoHistory").setAttribute("command", "Browser:PrevTab");

                    /// Next: Ctrl-L
                    window.document.getElementById("focusURLBar").setAttribute("command", "Browser:NextTab");

                    // Moving tabs
                    /// Backward: Ctrl-Shift-H
                    window.document.getElementById("cmd_file_importFromAnotherBrowser").setAttribute("oncommand", "gBrowser.moveTabBackward()");
                    window.document.getElementById("showAllHistoryKb").setAttribute("command", "cmd_file_importFromAnotherBrowser");

                    /// Forward: Ctrl-Shift-L
                    window.document.getElementById("cmd_help_importFromAnotherBrowser").setAttribute("oncommand", "gBrowser.moveTabForward()");
                    let addBookmarkAsKbEl = window.document.getElementById("addBookmarkAsKb");
                    addBookmarkAsKbEl.setAttribute("command", "cmd_help_importFromAnotherBrowser");
                    addBookmarkAsKbEl.setAttribute("data-l10n-id", "location-open-shortcut"); // L key
                    addBookmarkAsKbEl.setAttribute("modifiers", "accel,shift"); // Ctrl-Shift

                    // History
                    /// Backward: Alt-H
                    window.document.getElementById("goBackKb").setAttribute("keycode", "H");
                    window.document.getElementById("goForwardKb").setAttribute("keycode", "L");

                    /// Forward: Alt-L

                    // Focus location: Ctrl-O
                    window.document.getElementById("openFileKb").setAttribute("command", "Browser:OpenLocation");

                    // Disable bookmarks
                    // window.document.getElementById("addBookmarkAsKb").removeAttribute("command"); // Used for moving tabs ^
                    window.document.getElementById("bookmarkAllTabsKb").removeAttribute("oncommand");
                    let key = document.getElementById("viewBookmarksSidebarKb");
                    if (key) key.remove();
                  }
                }
              }
            };
            if (!Services.appinfo.inSafeMode) { new ConfigJS(); }
          } catch(ex) {};
        '';
      };
    };
  };
}
