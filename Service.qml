import QtQuick

// Headless entry point required by the Omarchy plugin contract.
// Wallpaper changes are issued by omarchy-theme-bg-set, which third-party
// plugins cannot wrap or intercept. The real hook is the PATH wrapper
// installed by scripts/install.sh. This item stays loaded so the plugin
// can be enabled, but it does not play clips or write any user files.
Item {
  id: root

  property var shell: null
  property var manifest: null
}
