pragma Singleton

import QtQuick
import "../services"

QtObject {
    id: root

    readonly property Rounding rounding: Rounding {}
    readonly property Spacing spacing: Spacing {}
    readonly property Padding padding: Padding {}
    readonly property FontStuff font: FontStuff {}
    readonly property Anim anim: Anim {}
    readonly property Debug debug: Debug {}

    // Rounding constants
    component Rounding: QtObject {
        readonly property int none: 0        // Disable rounding
        readonly property int tiny: 2        // For very small UI elements
        readonly property int small: 4       // For small rounded corners
        readonly property int smaller: 6     // For smaller buttons/elements
        readonly property int normal: 8      // Most common radius
        readonly property int larger: 12     // For medium buttons/panels
        readonly property int large: 16      // For large panels/windows
        readonly property int extraLarge: 20 // For major UI elements
        readonly property int full: 1000     // For pill shapes
    }

    // Spacing constants
    component Spacing: QtObject {
        readonly property int small: 7
        readonly property int smaller: 10
        readonly property int normal: 12
        readonly property int larger: 15
        readonly property int large: 20
    }

    // Padding constants
    component Padding: QtObject {
        readonly property int small: 5
        readonly property int smaller: 7
        readonly property int normal: 10
        readonly property int larger: 12
        readonly property int large: 15
    }

    // Font configuration
    component FontFamily: QtObject {
        // readonly property string sans: "Rubik"  // Updated to match end-4/dots-hyprland
        readonly property string sans: "SF Pro Display"
        readonly property string mono: "JetBrains Mono"
        readonly property string material: "Material Symbols Rounded"
        readonly property string materialIcons: "Material Icons"  // Alternative material icons
        readonly property string materialOutlined: "Material Symbols Outlined"  // Outlined material icons
        readonly property string display: "SF Pro Display"  // For display/heading text
    }

    component FontSize: QtObject {
        // Text sizes
        readonly property int tiny: 8           // For very small text
        readonly property int small: 9          // For small labels/tooltips
        readonly property int smaller: 10       // For secondary text
        readonly property int normal: 11        // For regular body text
        readonly property int body: 12          // For primary body text
        readonly property int medium: 13        // For medium text
        readonly property int large: 14         // For headers
        readonly property int larger: 15        // For large headers
        readonly property int title: 16         // For titles/headings

        // Icon sizes
        readonly property int iconSmall: 16     // For small icons
        readonly property int iconMedium: 18    // For medium icons (status)
        readonly property int iconLarge: 20     // For large icons (default MaterialIcon)
        readonly property int iconXLarge: 24    // For extra large icons (OSD)
    }

    component FontStuff: QtObject {
        readonly property FontFamily family: FontFamily {}
        readonly property FontSize size: FontSize {}
    }

    // Animation curves (Material Design 3 curves)
    component AnimCurves: QtObject {
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
        readonly property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
    }

    // Animation durations
    component AnimDurations: QtObject {
        readonly property int small: 200
        readonly property int normal: 400
        readonly property int large: 600
        readonly property int extraLarge: 1000
        readonly property int expressiveFastSpatial: 350
        readonly property int expressiveDefaultSpatial: 500
        readonly property int expressiveEffects: 200
    }

    component Anim: QtObject {
        readonly property AnimCurves curves: AnimCurves {}
        readonly property AnimDurations durations: AnimDurations {}
    }

    // Debug configuration
    component Debug: QtObject {
        property bool enabled: PersistentSettings.settings.debugEnabled
    }
}
