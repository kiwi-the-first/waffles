pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    // Theme configuration
    property string currentTheme: "dark" // "light", "dark", or "dynamic"
    property bool isDarkMode: currentTheme === "dark" || (currentTheme === "dynamic" && systemIsDark)
    property bool systemIsDark: true // This would be set by system detection

    // Helper functions for alpha transparency and interactive states
    function alpha(color, opacity) {
        return Qt.alpha(color, opacity);
    }

    function hoverColor(baseColor, hoverOpacity = 0.12) {
        return Qt.alpha(baseColor, hoverOpacity);
    }

    function pressedColor(baseColor, pressedOpacity = 0.16) {
        return Qt.alpha(baseColor, pressedOpacity);
    }

    function disabledColor(baseColor, disabledOpacity = 0.38) {
        return Qt.alpha(baseColor, disabledOpacity);
    }

    // Light Theme Colors
    readonly property var lightTheme: ({
            m3primary: "#6750a4",
            m3onPrimary: "#ffffff",
            m3primaryContainer: "#eaddff",
            m3onPrimaryContainer: "#21005d",
            m3secondary: "#625b71",
            m3onSecondary: "#ffffff",
            m3secondaryContainer: "#e8def8",
            m3onSecondaryContainer: "#1d192b",
            m3tertiary: "#7d5260",
            m3onTertiary: "#ffffff",
            m3tertiaryContainer: "#ffd8e4",
            m3onTertiaryContainer: "#31111d",
            m3error: "#ba1a1a",
            m3onError: "#ffffff",
            m3errorContainer: "#ffdad6",
            m3onErrorContainer: "#410002",
            m3surface: "#fffbfe",
            m3onSurface: "#1c1b1f",
            m3surfaceVariant: "#e7e0ec",
            m3onSurfaceVariant: "#49454f",
            m3surfaceContainer: "#f3edf7",
            m3surfaceContainerHigh: "#ece6f0",
            m3surfaceContainerHighest: "#e6e0e9",
            m3inverseSurface: "#313033",
            m3inverseOnSurface: "#f4eff4",
            m3outline: "#79747e",
            m3outlineVariant: "#cac4d0",
            m3shadow: "#000000",
            m3scrim: "#000000"
        })

    // Dark Theme Colors (current colors)
    readonly property var darkTheme: ({
            m3primary: "#d0bcff",
            m3onPrimary: "#371e73",
            m3primaryContainer: "#4f378b",
            m3onPrimaryContainer: "#eaddff",
            m3secondary: "#ccc2dc",
            m3onSecondary: "#332d41",
            m3secondaryContainer: "#4a4458",
            m3onSecondaryContainer: "#e8def8",
            m3tertiary: "#efb8c8",
            m3onTertiary: "#492532",
            m3tertiaryContainer: "#633b48",
            m3onTertiaryContainer: "#ffd8e4",
            m3error: "#f2b8b5",
            m3onError: "#601410",
            m3errorContainer: "#8c1d18",
            m3onErrorContainer: "#f9dedc",
            m3surface: "#1c1b1f",
            m3onSurface: "#e6e0e9",
            m3surfaceVariant: "#49454f",
            m3onSurfaceVariant: "#cac4d0",
            m3surfaceContainer: "#211f26",
            m3surfaceContainerHigh: "#2b2930",
            m3surfaceContainerHighest: "#36343b",
            m3inverseSurface: "#e6e0e9",
            m3inverseOnSurface: "#322f35",
            m3outline: "#938f99",
            m3outlineVariant: "#49454f",
            m3shadow: "#000000",
            m3scrim: "#000000"
        })

    // Material Design 3 Color Palette - Theme-aware
    readonly property color m3primary: isDarkMode ? darkTheme.m3primary : lightTheme.m3primary
    readonly property color m3onPrimary: isDarkMode ? darkTheme.m3onPrimary : lightTheme.m3onPrimary
    readonly property color m3primaryContainer: isDarkMode ? darkTheme.m3primaryContainer : lightTheme.m3primaryContainer
    readonly property color m3onPrimaryContainer: isDarkMode ? darkTheme.m3onPrimaryContainer : lightTheme.m3onPrimaryContainer

    readonly property color m3secondary: isDarkMode ? darkTheme.m3secondary : lightTheme.m3secondary
    readonly property color m3onSecondary: isDarkMode ? darkTheme.m3onSecondary : lightTheme.m3onSecondary
    readonly property color m3secondaryContainer: isDarkMode ? darkTheme.m3secondaryContainer : lightTheme.m3secondaryContainer
    readonly property color m3onSecondaryContainer: isDarkMode ? darkTheme.m3onSecondaryContainer : lightTheme.m3onSecondaryContainer

    readonly property color m3tertiary: isDarkMode ? darkTheme.m3tertiary : lightTheme.m3tertiary
    readonly property color m3onTertiary: isDarkMode ? darkTheme.m3onTertiary : lightTheme.m3onTertiary
    readonly property color m3tertiaryContainer: isDarkMode ? darkTheme.m3tertiaryContainer : lightTheme.m3tertiaryContainer
    readonly property color m3onTertiaryContainer: isDarkMode ? darkTheme.m3onTertiaryContainer : lightTheme.m3onTertiaryContainer

    readonly property color m3error: isDarkMode ? darkTheme.m3error : lightTheme.m3error
    readonly property color m3onError: isDarkMode ? darkTheme.m3onError : lightTheme.m3onError
    readonly property color m3errorContainer: isDarkMode ? darkTheme.m3errorContainer : lightTheme.m3errorContainer
    readonly property color m3onErrorContainer: isDarkMode ? darkTheme.m3onErrorContainer : lightTheme.m3onErrorContainer

    readonly property color m3surface: isDarkMode ? darkTheme.m3surface : lightTheme.m3surface
    readonly property color m3onSurface: isDarkMode ? darkTheme.m3onSurface : lightTheme.m3onSurface
    readonly property color m3surfaceVariant: isDarkMode ? darkTheme.m3surfaceVariant : lightTheme.m3surfaceVariant
    readonly property color m3onSurfaceVariant: isDarkMode ? darkTheme.m3onSurfaceVariant : lightTheme.m3onSurfaceVariant

    readonly property color m3surfaceContainer: isDarkMode ? darkTheme.m3surfaceContainer : lightTheme.m3surfaceContainer
    readonly property color m3surfaceContainerHigh: isDarkMode ? darkTheme.m3surfaceContainerHigh : lightTheme.m3surfaceContainerHigh
    readonly property color m3surfaceContainerHighest: isDarkMode ? darkTheme.m3surfaceContainerHighest : lightTheme.m3surfaceContainerHighest

    readonly property color m3inverseSurface: isDarkMode ? darkTheme.m3inverseSurface : lightTheme.m3inverseSurface
    readonly property color m3inverseOnSurface: isDarkMode ? darkTheme.m3inverseOnSurface : lightTheme.m3inverseOnSurface

    readonly property color m3outline: isDarkMode ? darkTheme.m3outline : lightTheme.m3outline
    readonly property color m3outlineVariant: isDarkMode ? darkTheme.m3outlineVariant : lightTheme.m3outlineVariant

    readonly property color m3shadow: isDarkMode ? darkTheme.m3shadow : lightTheme.m3shadow
    readonly property color m3scrim: isDarkMode ? darkTheme.m3scrim : lightTheme.m3scrim

    // Theme switching function for future dynamic color support
    function setTheme(themeName) {
        if (themeName === "light" || themeName === "dark" || themeName === "dynamic") {
            root.currentTheme = themeName;
        }
    }

    // Dynamic color source (placeholder for future implementation)
    property var dynamicColorSource: null

    function updateDynamicColors(colorSource) {
        // Future implementation for dynamic colors from wallpaper/image
        // This would use Material Design 3's dynamic color algorithms to:
        // 1. Extract key colors from the source image/wallpaper
        // 2. Generate a complete color scheme using HCT (Hue, Chroma, Tone) color space
        // 3. Create both light and dark variants
        // 4. Update lightTheme and darkTheme objects with new colors
        root.dynamicColorSource = colorSource;

    // Example future implementation:
    // const keyColor = extractDominantColor(colorSource);
    // const scheme = generateMaterialScheme(keyColor);
    // root.lightTheme = scheme.light;
    // root.darkTheme = scheme.dark;
    }

    // System theme detection (placeholder for future implementation)
    function updateSystemTheme() {
    // This would detect system dark/light mode preference
    // root.systemIsDark = getSystemDarkModePreference();
    }

    // Semantic color mappings for UI components
    readonly property QtObject semantic: QtObject {
        // Text colors
        readonly property color textPrimary: root.m3onSurface         // "#e6e0e9"
        readonly property color textSecondary: root.m3onSurfaceVariant // "#cac4d0"
        readonly property color textDisabled: root.alpha(root.m3onSurface, 0.38)
        readonly property color textAccent: root.m3primary            // "#d0bcff"
        readonly property color textError: root.m3error               // "#f2b8b5"

        // Background colors
        readonly property color backgroundMain: root.m3surface        // "#1c1b1f"
        readonly property color backgroundSurface: root.m3surfaceContainer
        readonly property color backgroundElevated: root.m3surfaceContainerHigh
        readonly property color backgroundHighest: root.m3surfaceContainerHighest

        // Border colors
        readonly property color borderSubtle: root.alpha(root.m3outline, 0.2)    // Qt.alpha("#938f99", 0.2)
        readonly property color borderNormal: root.alpha(root.m3outline, 0.3)    // Qt.alpha("#938f99", 0.3)
        readonly property color borderStrong: root.m3outline               // "#938f99"

        // Accent/Primary colors
        readonly property color accent: root.m3primary                     // "#d0bcff"
        readonly property color accentHover: root.hoverColor(root.m3primary)    // Qt.alpha("#d0bcff", 0.12)
        readonly property color accentPressed: root.pressedColor(root.m3primary) // Qt.alpha("#d0bcff", 0.16)
        readonly property color accentSubtle: root.alpha(root.m3primary, 0.08)  // Qt.alpha("#d0bcff", 0.08)
        readonly property color accentMuted: root.alpha(root.m3primary, 0.1)    // Qt.alpha("#d0bcff", 0.1)

        // Interactive state colors
        readonly property color hover: root.hoverColor(root.m3primary)          // For hover effects
        readonly property color pressed: root.pressedColor(root.m3primary)      // For pressed states
        readonly property color disabled: root.disabledColor(root.m3onSurface)  // For disabled elements

        // Special purpose colors
        readonly property color shadow: root.alpha(root.m3shadow, 0.3)          // Qt.alpha("#000000", 0.3)
        readonly property color overlay: root.alpha(root.m3shadow, 0.5)         // For modal overlays
        readonly property color transparent: "transparent"

        // Component-specific colors
        readonly property color sliderTrack: root.m3surfaceContainerHigh        // Dark container for track
        readonly property color sliderActiveTrack: root.m3primary               // Primary color for active portion
        readonly property color sliderHandle: root.m3surface                    // Handle background
        readonly property color sliderHandleActive: root.m3onSurface            // Handle when pressed/moving
        readonly property color sliderBorder: root.alpha(root.m3outline, 0.5)  // Outline with transparency
        readonly property color sliderText: root.m3onSurface                    // Text on handle
    }
}
