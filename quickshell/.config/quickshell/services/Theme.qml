pragma Singleton
import QtQuick

QtObject {
    // Typography
    readonly property string fontFamily: "Hack Nerd Font"
    readonly property string fontFamilyMono: "Hack Nerd Font"
    // readonly property string fontFamily: "Adwaita Sans"
    // readonly property string fontFamilyMono: "Hack Nerd Font"
    
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeMedium: 15
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeXLarge: 17
    readonly property int fontSizeHuge: 20
    readonly property int fontSizeTitle: 24
    
    readonly property int fontWeightLight: 300
    readonly property int fontWeightNormal: 500
    readonly property int fontWeightBold: 600
    readonly property int fontWeightExtraBold: 700
    
    // Icon sizes
    readonly property int iconSizeSmall: 14
    readonly property int iconSizeNormal: 16
    readonly property int iconSizeMedium: 17
    readonly property int iconSizeLarge: 18
    readonly property int iconSizeHuge: 19
    
    // Component sizes
    readonly property int moduleHeight: 28
    readonly property int moduleRadius: 14
    readonly property int pillRadius: 13
    readonly property int pillHeight: 26
    
    // Ring/Progress indicators
    readonly property int ringWidth: 3
    readonly property real ringInset: 0.5
    
    // Spacing
    readonly property int spacingTiny: 2
    readonly property int spacingSmall: 4
    readonly property int spacingNormal: 6
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 10
    readonly property int spacingXLarge: 12
    readonly property int spacingHuge: 16
    
    // Padding
    readonly property int paddingSmall: 4
    readonly property int paddingNormal: 6
    readonly property int paddingMedium: 10
    readonly property int paddingLarge: 12
    readonly property int paddingXLarge: 16
    readonly property int paddingContent: 18
    readonly property int paddingModule: 22
    
    // Animation timings
    readonly property int animDurationFast: 90
    readonly property int animDurationNormal: 120
    readonly property int animDurationMedium: 140
    readonly property int animDurationSlow: 160
    readonly property int animDurationVerySlow: 180
    readonly property int animDurationBounce: 220
    
    // Colors - Catppuccin Mocha palette
    readonly property color colorBase: "#1e1e2e"
    readonly property color colorMantle: "#181825"
    readonly property color colorCrust: "#11111b"
    
    readonly property color colorSurface0: "#313244"
    readonly property color colorSurface1: "#45475a"
    readonly property color colorSurface2: "#585b70"
    
    readonly property color colorOverlay0: '#53555f'
    readonly property color colorOverlay1: "#7f849c"
    readonly property color colorOverlay2: "#9399b2"
    
    readonly property color colorSubtext0: "#a6adc8"
    readonly property color colorSubtext1: "#bac2de"
    
    readonly property color colorText: "#cdd6f4"
    readonly property color colorTextBright: "#f1f5ff"
    
    readonly property color colorLavender: "#b4befe"
    readonly property color colorBlue: "#89b4fa"
    readonly property color colorSapphire: "#74c7ec"
    readonly property color colorSky: "#89dceb"
    readonly property color colorTeal: "#94e2d5"
    readonly property color colorGreen: "#a6e3a1"
    readonly property color colorYellow: "#f9e2af"
    readonly property color colorPeach: "#fab387"
    readonly property color colorMaroon: "#eba0ac"
    readonly property color colorRed: "#f38ba8"
    readonly property color colorMauve: "#cba6f7"
    readonly property color colorPink: "#f5c2e7"
    readonly property color colorFlamingo: "#f2cdcd"
    readonly property color colorRosewater: "#f5e0dc"
    readonly property color colorBlack: "#000000"
    readonly property color colorWhite: "#ffffff"
    
    // Semantic colors
    readonly property color colorSuccess: colorGreen
    readonly property color colorWarning: colorYellow
    readonly property color colorError: colorRed
    readonly property color colorInfo: colorBlue
    
    readonly property color colorAccent: colorLavender
    readonly property color colorAccentSecondary: colorBlue
    
    // Component-specific colors
    readonly property color colorButtonBg: colorSurface0
    readonly property color colorButtonHover: "#2f3042"
    readonly property color colorButtonPress: "#2a2b3a"
    
    readonly property color colorCardBg: colorBase
    readonly property color colorCardBgAlt: colorMantle
    readonly property color colorCardBorder: colorSurface0
    
    readonly property color colorRingBg: colorText
    readonly property color colorRingFgLow: colorGreen
    readonly property color colorRingFgMedium: colorYellow
    readonly property color colorRingFgHigh: colorRed
    
    // Opacity levels
    readonly property real opacityDisabled: 0.45
    readonly property real opacityMuted: 0.7
    readonly property real opacitySubtle: 0.85
    readonly property real opacityNormal: 0.95
    readonly property real opacityFull: 1.0
    readonly property real opacityRingBg: 0.22
    
    // Shadow settings
    readonly property int shadowPadding: 10
    readonly property real shadowOpacity: 0.28
    readonly property real shadowBlur: 0.55
    readonly property int shadowOffsetY: 6
    
    // Hover/Press scales
    readonly property real scaleHover: 1.03
    readonly property real scalePress: 0.96
    readonly property real scalePressSmall: 0.985
    readonly property real scaleHoverSmall: 1.02
    readonly property real scaleHoverButton: 1.08
    readonly property real scalePressButton: 0.92
    
    // Tooltip/slideout settings
    readonly property int tooltipGap: 3
    readonly property int tooltipHiddenOffset: 2
    readonly property int tooltipMinClosedWidth: 0
}
