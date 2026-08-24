.pragma library

// Icon name -> Nerd Font glyph. Callers pass names ("volume-high"), never
// codepoints, so shell scripts never contain literal glyphs and the mapping can
// change in one place. All of these are verified present in the installed
// Nerd Fonts.
var ICONS = {
    "volume-high":      "E",
    "volume-medium":    "0",
    "volume-low":       "F",
    "volume-muted":     "F",
    "mic":              "C",
    "mic-muted":        "D",
    "brightness-high":  "0",
    "brightness-medium":"F",
    "brightness-low":   "E",
}

// Widest glyph per family. A progress OSD pins its icon column to this so the
// bar does not shift sideways when the level crosses an icon threshold.
var FAMILIES = {
    "volume":     ["volume-muted", "volume-low", "volume-medium", "volume-high"],
    "mic":        ["mic", "mic-muted"],
    "brightness": ["brightness-low", "brightness-medium", "brightness-high"],
}

function glyph(name) {
    return ICONS[name] !== undefined ? ICONS[name] : ""
}

function familyOf(name) {
    for (var family in FAMILIES)
        if (FAMILIES[family].indexOf(name) !== -1)
            return family
    return ""
}

// Every glyph a given icon's family can produce, so the icon column can be
// measured against the widest of them rather than the current one.
function familyGlyphs(name) {
    var family = familyOf(name)
    if (family === "")
        return [glyph(name)]
    return FAMILIES[family].map(glyph)
}

function clampNumber(value, lo, hi) {
    var n = Number(value)
    if (!isFinite(n))
        return lo
    return Math.max(lo, Math.min(hi, n))
}

// Normalize an IPC payload into what the view binds to. `hasProgress` is derived
// rather than passed: a numeric value with no message means a level readout, a
// message means a plain toast.
function normalize(payloadJson) {
    var p = {}
    try {
        p = JSON.parse(payloadJson || "{}") || {}
    } catch (e) {
        p = {}
    }

    var rawValue = p.value === undefined || p.value === null ? "" : String(p.value)
    var message = p.message === undefined || p.message === null ? "" : String(p.message)
    var parsed = Number(rawValue)
    var hasProgress = rawValue !== "" && isFinite(parsed) && message === ""

    var max = clampNumber(p.max, 1, 1000000)
    if (!isFinite(Number(p.max)) || Number(p.max) <= 0)
        max = 100

    var duration = Number(p.duration)
    if (!isFinite(duration) || duration <= 0)
        duration = 1500

    var iconName = p.icon === undefined || p.icon === null ? "" : String(p.icon)

    return {
        iconName: iconName,
        glyph: glyph(iconName),
        familyGlyphs: familyGlyphs(iconName),
        message: message,
        hasProgress: hasProgress,
        value: hasProgress ? clampNumber(parsed, 0, max) : 0,
        max: max,
        progressText: hasProgress
            ? (p.progressText ? String(p.progressText)
                              : String(Math.round((clampNumber(parsed, 0, max) / max) * 100)) + "%")
            : "",
        duration: duration,
    }
}
