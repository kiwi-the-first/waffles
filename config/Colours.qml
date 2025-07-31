pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property Palette palette: Palette {}

    // Helper function for alpha transparency
    function alpha(color, transparent) {
        return Qt.alpha(color, transparent ? 0.08 : 1.0);
    }

    // Material Design 3 Color Palette
    component Palette: QtObject {
        // Primary colors
        readonly property color m3primary: "#d0bcff"
        readonly property color m3onPrimary: "#371e73"
        readonly property color m3primaryContainer: "#4f378b"
        readonly property color m3onPrimaryContainer: "#eaddff"

        // Secondary colors
        readonly property color m3secondary: "#ccc2dc"
        readonly property color m3onSecondary: "#332d41"
        readonly property color m3secondaryContainer: "#4a4458"
        readonly property color m3onSecondaryContainer: "#e8def8"

        // Tertiary colors
        readonly property color m3tertiary: "#efb8c8"
        readonly property color m3onTertiary: "#492532"
        readonly property color m3tertiaryContainer: "#633b48"
        readonly property color m3onTertiaryContainer: "#ffd8e4"

        // Error colors
        readonly property color m3error: "#f2b8b5"
        readonly property color m3onError: "#601410"
        readonly property color m3errorContainer: "#8c1d18"
        readonly property color m3onErrorContainer: "#f9dedc"

        // Surface colors
        readonly property color m3surface: "#1c1b1f"
        readonly property color m3onSurface: "#e6e0e9"
        readonly property color m3surfaceVariant: "#49454f"
        readonly property color m3onSurfaceVariant: "#cac4d0"

        // Surface containers
        readonly property color m3surfaceContainer: "#211f26"
        readonly property color m3surfaceContainerHigh: "#2b2930"
        readonly property color m3surfaceContainerHighest: "#36343b"

        // Inverse colors
        readonly property color m3inverseSurface: "#e6e0e9"
        readonly property color m3inverseOnSurface: "#322f35"

        // Outline colors
        readonly property color m3outline: "#938f99"
        readonly property color m3outlineVariant: "#49454f"

        // Shadow and scrim
        readonly property color m3shadow: "#000000"
        readonly property color m3scrim: "#000000"
    }
}
