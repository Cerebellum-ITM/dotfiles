#!/bin/bash

gum_custom_color_style() {
    text=$1
    color=$2
    gum style --foreground "$color" "$text"
}

# Functions for gum styles using neon or pastel colors
gum_blue() {
    gum style --foreground="#00BFFF" "$1"  # Deep Sky Blue (Neon)
}

gum_blue_dark() {
    gum style --foreground="#0000CD" "$1"  # Medium Blue (Darker)
}

gum_red() {
    gum style --foreground="#FF1493" "$1"  # Deep Pink (Neon)
}

gum_red_dark() {
    gum style --foreground="#8B0000" "$1"  # Dark Red
}

gum_green() {
    gum style --foreground="#32CD32" "$1"  # Lime Green (Neon)
}

gum_green_dark() {
    gum style --foreground="#228B22" "$1"  # Forest Green
}

gum_yellow() {
    gum style --foreground="#FFD700" "$1"  # Gold (Pastel)
}

gum_yellow_dark() {
    gum style --foreground="#B8860B" "$1"  # Dark Goldenrod
}

gum_purple() {
    gum style --foreground="#9370DB" "$1"  # Medium Purple (Pastel)
}

gum_purple_dark() {
    gum style --foreground="#6A5ACD" "$1"  # Slate Blue
}

gum_cyan() {
    gum style --foreground="#00CED1" "$1"  # Dark Turquoise (Neon)
}

gum_cyan_dark() {
    gum style --foreground="#008B8B" "$1"  # Dark Cyan
}

# Underlined variants
gum_blue_underline() {
    gum style --foreground="#00BFFF" --underline "$1"  # Deep Sky Blue Underlined
}

gum_blue_dark_underline() {
    gum style --foreground="#0000CD" --underline "$1"  # Medium Blue Underlined
}

gum_red_underline() {
    gum style --foreground="#FF1493" --underline "$1"  # Deep Pink Underlined
}

gum_red_dark_underline() {
    gum style --foreground="#8B0000" --underline "$1"  # Dark Red Underlined
}

gum_green_underline() {
    gum style --foreground="#32CD32" --underline "$1"  # Lime Green Underlined
}

gum_green_dark_underline() {
    gum style --foreground="#228B22" --underline "$1"  # Forest Green Underlined
}

gum_yellow_underline() {
    gum style --foreground="#FFD700" --underline "$1"  # Gold Underlined
}

gum_yellow_dark_underline() {
    gum style --foreground="#B8860B" --underline "$1"  # Dark Goldenrod Underlined
}

gum_purple_underline() {
    gum style --foreground="#9370DB" --underline "$1"  # Medium Purple Underlined
}

gum_purple_dark_underline() {
    gum style --foreground="#6A5ACD" --underline "$1"  # Slate Blue Underlined
}

gum_cyan_underline() {
    gum style --foreground="#00CED1" --underline "$1"  # Dark Turquoise Underlined
}

gum_cyan_dark_underline() {
    gum style --foreground="#008B8B" --underline "$1"  # Dark Cyan Underlined
}

# Bold variants
gum_blue_bold() {
    gum style --foreground="#00BFFF" --bold "$1"  # Deep Sky Blue Bold
}

gum_blue_dark_bold() {
    gum style --foreground="#0000CD" --bold "$1"  # Medium Blue Bold
}

gum_red_bold() {
    gum style --foreground="#FF1493" --bold "$1"  # Deep Pink Bold
}

gum_red_dark_bold() {
    gum style --foreground="#8B0000" --bold "$1"  # Dark Red Bold
}

gum_green_bold() {
    gum style --foreground="#32CD32" --bold "$1"  # Lime Green Bold
}

gum_green_dark_bold() {
    gum style --foreground="#228B22" --bold "$1"  # Forest Green Bold
}

gum_yellow_bold() {
    gum style --foreground="#FFD700" --bold "$1"  # Gold Bold
}

gum_yellow_dark_bold() {
    gum style --foreground="#B8860B" --bold "$1"  # Dark Goldenrod Bold
}

gum_purple_bold() {
    gum style --foreground="#9370DB" --bold "$1"  # Medium Purple Bold
}

gum_purple_dark_bold() {
    gum style --foreground="#6A5ACD" --bold "$1"  # Slate Blue Bold
}

gum_cyan_bold() {
    gum style --foreground="#00CED1" --bold "$1"  # Dark Turquoise Bold
}

gum_cyan_dark_bold() {
    gum style --foreground="#008B8B" --bold "$1"  # Dark Cyan Bold
}

# Bold and Underlined variants
gum_blue_bold_underline() {
    gum style --foreground="#00BFFF" --bold --underline "$1"  # Deep Sky Blue Bold and Underlined
}

gum_blue_dark_bold_underline() {
    gum style --foreground="#0000CD" --bold --underline "$1"  # Medium Blue Bold and Underlined
}

gum_red_bold_underline() {
    gum style --foreground="#FF1493" --bold --underline "$1"  # Deep Pink Bold and Underlined
}

gum_red_dark_bold_underline() {
    gum style --foreground="#8B0000" --bold --underline "$1"  # Dark Red Bold and Underlined
}

gum_green_bold_underline() {
    gum style --foreground="#32CD32" --bold --underline "$1"  # Lime Green Bold and Underlined
}

gum_green_dark_bold_underline() {
    gum style --foreground="#228B22" --bold --underline "$1"  # Forest Green Bold and Underlined
}

gum_yellow_bold_underline() {
    gum style --foreground="#FFD700" --bold --underline "$1"  # Gold Bold and Underlined
}

gum_yellow_dark_bold_underline() {
    gum style --foreground="#B8860B" --bold --underline "$1"  # Dark Goldenrod Bold and Underlined
}

gum_purple_bold_underline() {
    gum style --foreground="#9370DB" --bold --underline "$1"  # Medium Purple Bold and Underlined
}

gum_purple_dark_bold_underline() {
    gum style --foreground="#6A5ACD" --bold --underline "$1"  # Slate Blue Bold and Underlined
}

gum_cyan_bold_underline() {
    gum style --foreground="#00CED1" --bold --underline "$1"  # Dark Turquoise Bold and Underlined
}

gum_cyan_dark_bold_underline() {
    gum style --foreground="#008B8B" --bold --underline "$1"  # Dark Cyan Bold and Underlined
}

#* Function to print all styles
gum_print_styles() {
    echo "gum_blue: $(gum_blue "Neon Blue text")"
    echo "gum_blue_dark: $(gum_blue_dark "Darker Blue text")"
    echo "gum_red: $(gum_red "Neon Red text")"
    echo "gum_red_dark: $(gum_red_dark "Darker Red text")"
    echo "gum_green: $(gum_green "Neon Green text")"
    echo "gum_green_dark: $(gum_green_dark "Darker Green text")"
    echo "gum_yellow: $(gum_yellow "Pastel Yellow text")"
    echo "gum_yellow_dark: $(gum_yellow_dark "Darker Yellow text")"
    echo "gum_purple: $(gum_purple "Pastel Purple text")"
    echo "gum_purple_dark: $(gum_purple_dark "Darker Purple text")"
    echo "gum_cyan: $(gum_cyan "Neon Cyan text")"
    echo "gum_cyan_dark: $(gum_cyan_dark "Darker Cyan text")"
    echo "gum_blue_underline: $(gum_blue_underline "Neon Blue underlined text")"
    echo "gum_blue_dark_underline: $(gum_blue_dark_underline "Darker Blue underlined text")"
    echo "gum_red_underline: $(gum_red_underline "Neon Red underlined text")"
    echo "gum_red_dark_underline: $(gum_red_dark_underline "Darker Red underlined text")"
    echo "gum_green_underline: $(gum_green_underline "Neon Green underlined text")"
    echo "gum_green_dark_underline: $(gum_green_dark_underline "Darker Green underlined text")"
    echo "gum_yellow_underline: $(gum_yellow_underline "Pastel Yellow underlined text")"
    echo "gum_yellow_dark_underline: $(gum_yellow_dark_underline "Darker Yellow underlined text")"
    echo "gum_purple_underline: $(gum_purple_underline "Pastel Purple underlined text")"
    echo "gum_purple_dark_underline: $(gum_purple_dark_underline "Darker Purple underlined text")"
    echo "gum_cyan_underline: $(gum_cyan_underline "Neon Cyan underlined text")"
    echo "gum_cyan_dark_underline: $(gum_cyan_dark_underline "Darker Cyan underlined text")"
    echo "gum_blue_bold: $(gum_blue_bold "Neon Blue bold text")"
    echo "gum_blue_dark_bold: $(gum_blue_dark_bold "Darker Blue bold text")"
    echo "gum_red_bold: $(gum_red_bold "Neon Red bold text")"
    echo "gum_red_dark_bold: $(gum_red_dark_bold "Darker Red bold text")"
    echo "gum_green_bold: $(gum_green_bold "Neon Green bold text")"
    echo "gum_green_dark_bold: $(gum_green_dark_bold "Darker Green bold text")"
    echo "gum_yellow_bold: $(gum_yellow_bold "Pastel Yellow bold text")"
    echo "gum_yellow_dark_bold: $(gum_yellow_dark_bold "Darker Yellow bold text")"
    echo "gum_purple_bold: $(gum_purple_bold "Pastel Purple bold text")"
    echo "gum_purple_dark_bold: $(gum_purple_dark_bold "Darker Purple bold text")"
    echo "gum_cyan_bold: $(gum_cyan_bold "Neon Cyan bold text")"
    echo "gum_cyan_dark_bold: $(gum_cyan_dark_bold "Darker Cyan bold text")"
    echo "gum_blue_bold_underline: $(gum_blue_bold_underline "Neon Blue bold and underlined text")"
    echo "gum_blue_dark_bold_underline: $(gum_blue_dark_bold_underline "Darker Blue bold and underlined text")"
    echo "gum_red_bold_underline: $(gum_red_bold_underline "Neon Red bold and underlined text")"
    echo "gum_red_dark_bold_underline: $(gum_red_dark_bold_underline "Darker Red bold and underlined text")"
    echo "gum_green_bold_underline: $(gum_green_bold_underline "Neon Green bold and underlined text")"
    echo "gum_green_dark_bold_underline: $(gum_green_dark_bold_underline "Darker Green bold and underlined text")"
    echo "gum_yellow_bold_underline: $(gum_yellow_bold_underline "Pastel Yellow bold and underlined text")"
    echo "gum_yellow_dark_bold_underline: $(gum_yellow_dark_bold_underline "Darker Yellow bold and underlined text")"
    echo "gum_purple_bold_underline: $(gum_purple_bold_underline "Pastel Purple bold and underlined text")"
    echo "gum_purple_dark_bold_underline: $(gum_purple_dark_bold_underline "Darker Purple bold and underlined text")"
    echo "gum_cyan_bold_underline: $(gum_cyan_bold_underline "Neon Cyan bold and underlined text")"
    echo "gum_cyan_dark_bold_underline: $(gum_cyan_dark_bold_underline "Darker Cyan bold and underlined text")"
}
