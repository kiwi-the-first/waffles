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
            // Browsers
            "firefox": "firefox",
            "google-chrome": "google-chrome",
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

            // Terminals
            "kitty": "kitty",
            "alacritty": "alacritty",
            "gnome-terminal": "gnome-terminal",
            "konsole": "konsole",
            "xterm": "xterm",
            "terminator": "terminator",

            // System
            "nautilus": "file-manager",
            "org.gnome.nautilus": "file-manager",
            "dolphin": "folder",
            "thunar": "folder",
            "pcmanfm": "folder",

            // Media
            "vlc": "vlc",
            "mpv": "mpv",
            "spotify": "spotify",
            "discord": "discord",

            // Office
            "libreoffice": "libreoffice-startcenter",
            "writer": "libreoffice-writer",
            "calc": "libreoffice-calc",
            "impress": "libreoffice-impress",

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
            , lowerClass.split("-")[0]         // get first part before dash
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
