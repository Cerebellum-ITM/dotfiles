# shellcheck shell=bash
#
# Foreground-color wrappers used across the dotfiles (logs, prompts, spinner
# titles). Public API (function names + colors) matches the previous version,
# but each wrapper now emits truecolor ANSI directly via printf instead of
# forking `gum style`. For the way these are used (single-line foreground +
# optional bold/underline, no padding/border/width), the ANSI bytes produced
# are identical to what `gum style --foreground=HEX [--bold] [--underline]`
# would emit — just ~100x faster per call because no subprocess is spawned.
#
# Use `gum` itself for everything else: `gum log`, `gum spin`, `gum choose`,
# `gum confirm`, `gum format`, etc. This file only replaces the per-fragment
# coloring helpers.

_GS_RESET=$'\033[0m'

# _gs_define <name> <hex> <bold:0|1> <underline:0|1>
# Precomputes the ANSI prefix once and defines a wrapper that does a single
# printf at call time.
_gs_define() {
    local name=$1 hex=$2 bold=${3:-0} ul=${4:-0}
    local r=$((16#${hex:1:2})) g=$((16#${hex:3:2})) b=$((16#${hex:5:2}))
    local prefix=$'\033['"38;2;${r};${g};${b}"
    [[ $bold == 1 ]] && prefix+=";1"
    [[ $ul   == 1 ]] && prefix+=";4"
    prefix+="m"
    eval "_GS_PFX_${name}=\$prefix"
    eval "${name}() { printf '%s%s\033[0m' \"\$_GS_PFX_${name}\" \"\$1\"; }"
}

# Ad-hoc color: accepts hex (#RRGGBB) on the fast path, falls back to
# `gum style` for non-hex inputs (e.g. 256-color indices) so existing callers
# that pass non-hex values keep working.
gum_custom_color_style() {
    local text=$1 color=$2
    if [[ $color == \#* && ${#color} -eq 7 ]]; then
        local r=$((16#${color:1:2})) g=$((16#${color:3:2})) b=$((16#${color:5:2}))
        printf '\033[38;2;%d;%d;%dm%s\033[0m' "$r" "$g" "$b" "$text"
    else
        gum style --foreground "$color" "$text"
    fi
}

# Palette: <name>:<hex>. Each entry generates plain / _bold / _underline /
# _bold_underline wrappers in the loop below, matching the original API.
_GS_PALETTE=(
    "gum_blue:#00BFFF"
    "gum_blue_dark:#0000CD"
    "gum_red:#FF1493"
    "gum_red_dark:#8B0000"
    "gum_green:#32CD32"
    "gum_green_dark:#228B22"
    "gum_yellow:#FFD700"
    "gum_yellow_dark:#B8860B"
    "gum_purple:#9370DB"
    "gum_purple_dark:#6A5ACD"
    "gum_cyan:#00CED1"
    "gum_cyan_dark:#008B8B"
    "git_red_orange:#F14E32"
    "git_red_orange_light:#FF7F5A"
    "git_red_orange_dark:#C6391E"
    "git_green:#32CD32"
    "git_green_light:#66FF66"
    "git_green_dark:#228B22"
    "git_strong_red:#FF0000"
    "git_strong_red_light:#FF4D4D"
    "git_strong_red_dark:#B22222"
    "git_strong_gray:#808080"
    "git_strong_gray_light:#A9A9A9"
    "git_strong_gray_dark:#696969"
    "git_strong_white:#FFFFFF"
    "git_strong_white_light:#F5F5F5"
    "git_strong_white_dark:#DCDCDC"
)

for _gs_entry in "${_GS_PALETTE[@]}"; do
    _gs_name=${_gs_entry%%:*}
    _gs_hex=${_gs_entry##*:}
    _gs_define "${_gs_name}"                "$_gs_hex" 0 0
    _gs_define "${_gs_name}_bold"           "$_gs_hex" 1 0
    _gs_define "${_gs_name}_underline"      "$_gs_hex" 0 1
    _gs_define "${_gs_name}_bold_underline" "$_gs_hex" 1 1
done
unset _gs_entry _gs_name _gs_hex

# Quick visual sanity check — prints every wrapper and its variants.
gum_print_styles() {
    local entry name hex
    for entry in "${_GS_PALETTE[@]}"; do
        name=${entry%%:*}
        hex=${entry##*:}
        printf '%-44s %s\n' "${name} (${hex}):"             "$("$name"                    "sample text")"
        printf '%-44s %s\n' "${name}_bold:"                  "$("${name}_bold"             "sample text")"
        printf '%-44s %s\n' "${name}_underline:"             "$("${name}_underline"        "sample text")"
        printf '%-44s %s\n' "${name}_bold_underline:"        "$("${name}_bold_underline"   "sample text")"
    done
}
