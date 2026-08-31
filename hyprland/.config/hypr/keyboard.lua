-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "altgr-intl",
        kb_model   = "",
        kb_options = "compose:menu",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        numlock_by_default = true,

        touchpad = {
            natural_scroll = true,
            -- Click anywhere with two fingers for right-click instead of aiming at
            -- the bottom-right corner of the pad.
            clickfinger_behavior = true,
        },
    },
})
