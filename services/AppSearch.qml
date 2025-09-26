pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.utils

QtObject {
    id: root

    // List of all desktop applications
    readonly property var list: Array.from(DesktopEntries.applications.values).sort((a, b) => a.name.localeCompare(b.name))

    // Function to search applications by name
    function fuzzyQuery(search) {
        if (!search || search.length === 0) {
            return [];
        }

        var query = search.toLowerCase();
        var results = [];

        // Search through desktop entries
        for (var i = 0; i < list.length; i++) {
            var app = list[i];
            var name = app.name ? app.name.toLowerCase() : "";
            var genericName = app.genericName ? app.genericName.toLowerCase() : "";
            var comment = app.comment ? app.comment.toLowerCase() : "";
            var keywords = app.keywords ? app.keywords.join(" ").toLowerCase() : "";

            // Check if search query matches app name, generic name, comment, or keywords
            if (name.includes(query) || genericName.includes(query) || comment.includes(query) || keywords.includes(query)) {
                var iconName = getAppIcon(app);
                DebugUtils.log("App:", app.name, "Icon:", iconName, "Icon path:", Quickshell.iconPath(iconName));

                results.push({
                    title: app.name || "Unknown Application",
                    description: app.comment || app.genericName || "",
                    type: "Application",
                    icon: iconName,
                    action: "launch",
                    data: app,
                    execute: function () {
                        if (this.data && this.data.execute) {
                            this.data.execute();
                        }
                    }
                });
            }
        }

        // Sort results by relevance (exact matches first)
        results.sort(function (a, b) {
            var aExact = a.title.toLowerCase().startsWith(query);
            var bExact = b.title.toLowerCase().startsWith(query);

            if (aExact && !bExact)
                return -1;
            if (!aExact && bExact)
                return 1;

            return a.title.localeCompare(b.title);
        });

        // Limit results to avoid UI clutter
        return results.slice(0, 10);
    }

    // Function to get appropriate icon for an application
    function getAppIcon(app) {
        if (!app) {
            return "application-x-executable";
        }

        // Use the icon name from the desktop entry
        if (app.icon && app.icon.length > 0) {
            return app.icon;
        }

        // Fallback to generic application icon
        return "application-x-executable";
    }

    // Function to guess icon from window class (useful for taskbars)
    function guessIcon(windowClass) {
        if (!windowClass) {
            return "application-x-executable";
        }

        // Common substitutions for window classes
        var substitutions = {
            "code": "visual-studio-code",
            "firefox": "firefox",
            "chromium": "chromium",
            "google-chrome": "google-chrome",
            "nautilus": "org.gnome.Nautilus",
            "dolphin": "org.kde.dolphin",
            "thunar": "thunar",
            "konsole": "org.kde.konsole",
            "gnome-terminal": "org.gnome.Terminal",
            "kitty": "kitty",
            "alacritty": "Alacritty",
            "discord": "discord",
            "telegram": "telegram",
            "spotify": "spotify",
            "steam": "steam"
        };

        var lowerClass = windowClass.toLowerCase();
        if (substitutions[lowerClass]) {
            return substitutions[lowerClass];
        }

        // Try to find desktop entry by matching app ID
        for (var i = 0; i < list.length; i++) {
            var app = list[i];
            if (app.id && app.id.toLowerCase().includes(lowerClass)) {
                return app.icon || "application-x-executable";
            }
        }

        return windowClass;
    }
}
