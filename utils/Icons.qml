//@ pragma IconTheme Papirus-Dark
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    // Get application icon path
    function getAppIcon(appClass) {
        if (!appClass)
            return getAppCategoryIcon("application-x-executable");

        // Convert class to lowercase for better matching
        const lowerClass = appClass.toLowerCase();

        // Direct icon name mappings for common applications
        const iconMappings = {
            "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-default": "whatsapp",
            "net.nokyan.resources": "gnome-monitor",
            // Browsers
            "firefox": "firefox",
            "google-chrome": "google-chrome",
            "com.google.chrome": "google-chrome",
            "chromium": "chromium",
            "brave": "brave-browser",
            "zen": "zen-browser",

            // Development
            "code": "vscode",
            "codium": "vscodium",
            "visual studio code": "vscode",
            "atom": "atom",
            "sublime": "sublime-text",
            "jetbrains": "jetbrains-toolbox",
            "jetbrains-idea-ce": "intellij-idea-ce",
            "android-studio": "android-studio",
            "jetbrains-studio": "android-studio",
            "cmake-gui": "cmake",
            "designer": "designer",
            "dev.zed.zed": "zed",

            // Terminals
            "kitty": "kitty",
            "alacritty": "alacritty",
            "gnome-terminal": "gnome-terminal",
            "org.gnome.console": "gnome-terminal",
            "org.gnome.terminal": "gnome-terminal",
            "konsole": "konsole",
            "xterm": "xterm",
            "terminator": "terminator",
            "btop": "htop",

            // System & Utilities
            "nautilus": "nautilus",
            "org.gnome.nautilus": "nautilus",
            // "org.gnome.nautilus": "org.gnome.Nautilus",
            "dolphin": "folder",
            "thunar": "folder",
            "pcmanfm": "folder",
            "blueman-manager": "bluetooth",
            "blueman-adapters": "bluetooth",
            "bluetooth-sendto": "bluetooth",
            "avahi-discover": "network-workgroup",

            // Media & Entertainment
            "vlc": "vlc",
            "mpv": "mpv",
            "spotify": "spotify",
            "discord": "discord",
            "com.obsproject.studio": "obs-studio",

            // Office & Productivity
            "assistant": "assistant",

            // Remote Access & Network
            "bssh": "ssh",
            "bvnc": "krdc",
            "gcm-import": "preferences-system",

            // System Configuration
            "breezestyleconfig": "preferences-desktop-theme",

            // Generic Applications
            "electron34": "application-x-executable",

            // Text Editors
            "org.gnome.texteditor": "text-editor",
            "org.gnome.gedit": "text-editor",
            "gedit": "text-editor",
            "mousepad": "text-editor",
            "leafpad": "text-editor",
            "kate": "kate",
            "geany": "geany",
            "nano": "text-editor",
            "vim": "text-editor",
            "emacs": "emacs",

            // Office
            "libreoffice": "libreoffice-startcenter",
            "writer": "libreoffice-writer",
            "calc": "libreoffice-calc",
            "impress": "libreoffice-impress",
            "org.gnome.evince": "evince",

            // Graphics
            "gimp": "gimp",
            "inkscape": "inkscape",
            "blender": "blender",
            "krita": "krita"
        };

        // Check direct mapping first
        if (iconMappings[lowerClass]) {
            const iconPath = Quickshell.iconPath(iconMappings[lowerClass]);
            if (iconPath)
                return iconPath;
        }

        // Try original class name
        let iconPath = Quickshell.iconPath(lowerClass);
        if (iconPath)
            return iconPath;

        // Try with common suffixes removed
        const cleanedClass = lowerClass.replace(/-desktop$|\.desktop$|_desktop$/, "");
        iconPath = Quickshell.iconPath(cleanedClass);
        if (iconPath)
            return iconPath;

        // Try some common variations
        const variations = [lowerClass.replace(/\./g, "-")  // org.gnome.nautilus -> org-gnome-nautilus
            , lowerClass.split(".").pop()     // org.gnome.nautilus -> nautilus
            , lowerClass.split("-")[0]        // get first part before dash
            , lowerClass.replace(/^com\./, "") // com.google.chrome -> google.chrome
            , lowerClass.replace(/^org\./, "") // org.gnome.console -> gnome.console
            , lowerClass.replace(/^dev\./, "")  // dev.zed.zed -> zed.zed
        ];

        for (const variation of variations) {
            iconPath = Quickshell.iconPath(variation);
            if (iconPath)
                return iconPath;
        }

        // Fallback to generic application icon
        return getAppCategoryIcon("application-x-executable");
    }

    // Get category-based fallback icons
    function getAppCategoryIcon(category) {
        const categoryIcons = {
            "application-x-executable": "application-x-executable",
            "text-editor": "text-editor",
            "web-browser": "web-browser",
            "file-manager": "file-manager",
            "terminal": "terminal",
            "media-player": "media-player",
            "graphics": "applications-graphics",
            "office": "applications-office",
            "development": "applications-development",
            "system": "applications-system"
        };

        const iconName = categoryIcons[category] || "application-x-executable";
        return Quickshell.iconPath(iconName) || Quickshell.iconPath("application-x-executable") || ""; // Return empty string if no icon found
    }
}
