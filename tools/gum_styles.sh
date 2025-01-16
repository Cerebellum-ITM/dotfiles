# shellcheck shell=bash

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

git_red_orange() {
    gum style --foreground="#F14E32" "$1"  # Base Color (Red Orange)
}

git_red_orange_light() {
    gum style --foreground="#FF7F5A" "$1"  # Light Red Orange
}

git_red_orange_dark() {
    gum style --foreground="#C6391E" "$1"  # Dark Red Orange
}

git_red_orange_bold() {
    gum style --foreground="#F14E32" --bold "$1"  # Bold Red Orange
}

git_red_orange_light_bold() {
    gum style --foreground="#FF7F5A" --bold "$1"  # Bold Light Red Orange
}

git_red_orange_dark_bold() {
    gum style --foreground="#C6391E" --bold "$1"  # Bold Dark Red Orange
}

git_red_orange_underline() {
    gum style --foreground="#F14E32" --underline "$1"  # Underlined Red Orange
}

git_red_orange_light_underline() {
    gum style --foreground="#FF7F5A" --underline "$1"  # Underlined Light Red Orange
}

git_red_orange_dark_underline() {
    gum style --foreground="#C6391E" --underline "$1"  # Underlined Dark Red Orange
}

# Functions for git colors using green shades
git_green() {
    gum style --foreground="#32CD32" "$1"  # Lime Green (Base)
}

git_green_light() {
    gum style --foreground="#66FF66" "$1"  # Light Green (Lighter Variant)
}

git_green_dark() {
    gum style --foreground="#228B22" "$1"  # Forest Green (Darker Variant)
}

git_green_bold() {
    gum style --foreground="#32CD32" --bold "$1"  # Lime Green Bold
}

git_green_light_bold() {
    gum style --foreground="#66FF66" --bold "$1"  # Light Green Bold
}

git_green_dark_bold() {
    gum style --foreground="#228B22" --bold "$1"  # Forest Green Bold
}

git_green_underline() {
    gum style --foreground="#32CD32" --underline "$1"  # Lime Green Underlined
}

git_green_light_underline() {
    gum style --foreground="#66FF66" --underline "$1"  # Light Green Underlined
}

git_green_dark_underline() {
    gum style --foreground="#228B22" --underline "$1"  # Forest Green Underlined
}

git_strong_red() {
    gum style --foreground="#FF0000" "$1"  # Strong Red (Base)
}

git_strong_red_light() {
    gum style --foreground="#FF4D4D" "$1"  # Light Strong Red
}

git_strong_red_dark() {
    gum style --foreground="#B22222" "$1"  # Firebrick Red (Darker Variant)
}

git_strong_red_bold() {
    gum style --foreground="#FF0000" --bold "$1"  # Bold Strong Red
}

git_strong_red_light_bold() {
    gum style --foreground="#FF4D4D" --bold "$1"  # Bold Light Strong Red
}

git_strong_red_dark_bold() {
    gum style --foreground="#B22222" --bold "$1"  # Bold Firebrick Red
}

git_strong_red_underline() {
    gum style --foreground="#FF0000" --underline "$1"  # Underlined Strong Red
}

git_strong_red_light_underline() {
    gum style --foreground="#FF4D4D" --underline "$1"  # Underlined Light Strong Red
}

git_strong_red_dark_underline() {
    gum style --foreground="#B22222" --underline "$1"  # Underlined Firebrick Red
}

git_strong_gray() {
    gum style --foreground="#808080" "$1"  # Strong Gray (Base)
}

git_strong_gray_light() {
    gum style --foreground="#A9A9A9" "$1"  # Light Gray
}

git_strong_gray_dark() {
    gum style --foreground="#696969" "$1"  # Dark Gray
}

git_strong_gray_bold() {
    gum style --foreground="#808080" --bold "$1"  # Bold Strong Gray
}

git_strong_gray_light_bold() {
    gum style --foreground="#A9A9A9" --bold "$1"  # Bold Light Gray
}

git_strong_gray_dark_bold() {
    gum style --foreground="#696969" --bold "$1"  # Bold Dark Gray
}

git_strong_gray_underline() {
    gum style --foreground="#808080" --underline "$1"  # Underlined Strong Gray
}

git_strong_gray_light_underline() {
    gum style --foreground="#A9A9A9" --underline "$1"  # Underlined Light Gray
}

git_strong_gray_dark_underline() {
    gum style --foreground="#696969" --underline "$1"  # Underlined Dark Gray
}

# Functions for git colors using neon white
git_strong_white() {
    gum style --foreground="#FFFFFF" "$1"  # Strong White (Base)
}

git_strong_white_light() {
    gum style --foreground="#F5F5F5" "$1"  # Light White (Very Light Gray)
}

git_strong_white_dark() {
    gum style --foreground="#DCDCDC" "$1"  # Dark White (Gainsboro)
}

git_strong_white_bold() {
    gum style --foreground="#FFFFFF" --bold "$1"  # Bold Strong White
}

git_strong_white_light_bold() {
    gum style --foreground="#F5F5F5" --bold "$1"  # Bold Light White
}

git_strong_white_dark_bold() {
    gum style --foreground="#DCDCDC" --bold "$1"  # Bold Dark White
}

git_strong_white_underline() {
    gum style --foreground="#FFFFFF" --underline "$1"  # Underlined Strong White
}

git_strong_white_light_underline() {
    gum style --foreground="#F5F5F5" --underline "$1"  # Underlined Light White
}

git_strong_white_dark_underline() {
    gum style --foreground="#DCDCDC" --underline "$1"  # Underlined Dark White
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
    echo "git_red_orange: $(git_red_orange "This is Red Orange text.")"
    echo "git_red_orange_light: $(git_red_orange_light "This is Light Red Orange text.")"
    echo "git_red_orange_dark: $(git_red_orange_dark "This is Dark Red Orange text.")"
    echo "git_red_orange_bold: $(git_red_orange_bold "This is Bold Red Orange text.")"
    echo "git_red_orange_light_bold: $(git_red_orange_light_bold "This is Bold Light Red Orange text.")"
    echo "git_red_orange_dark_bold: $(git_red_orange_dark_bold "This is Bold Dark Red Orange text.")"
    echo "git_red_orange_underline: $(git_red_orange_underline "This is Underlined Red Orange text.")"
    echo "git_red_orange_light_underline: $(git_red_orange_light_underline "This is Underlined Light Red Orange text.")"
    echo "git_red_orange_dark_underline: $(git_red_orange_dark_underline "This is Underlined Dark Red Orange text.")"
    echo "git_green: $(git_green "This is Lime Green text.")"
    echo "git_green_light: $(git_green_light "This is Light Green text.")"
    echo "git_green_dark: $(git_green_dark "This is Dark Forest Green text.")"
    echo "git_green_bold: $(git_green_bold "This is Bold Lime Green text.")"
    echo "git_green_light_bold: $(git_green_light_bold "This is Bold Light Green text.")"
    echo "git_green_dark_bold: $(git_green_dark_bold "This is Bold Dark Forest Green text.")"
    echo "git_green_underline: $(git_green_underline "This is Underlined Lime Green text.")"
    echo "git_green_light_underline: $(git_green_light_underline "This is Underlined Light Green text.")"
    echo "git_green_dark_underline: $(git_green_dark_underline "This is Underlined Dark Forest Green text.")"
    echo "git_strong_red: $(git_strong_red "This is Strong Red text.")"
    echo "git_strong_red_light: $(git_strong_red_light "This is Light Strong Red text.")"
    echo "git_strong_red_dark: $(git_strong_red_dark "This is Dark Firebrick Red text.")"
    echo "git_strong_red_bold: $(git_strong_red_bold "This is Bold Strong Red text.")"
    echo "git_strong_red_light_bold: $(git_strong_red_light_bold "This is Bold Light Strong Red text.")"
    echo "git_strong_red_dark_bold: $(git_strong_red_dark_bold "This is Bold Firebrick Red text.")"
    echo "git_strong_red_underline: $(git_strong_red_underline "This is Underlined Strong Red text.")"
    echo "git_strong_red_light_underline: $(git_strong_red_light_underline "This is Underlined Light Strong Red text.")"
    echo "git_strong_red_dark_underline: $(git_strong_red_dark_underline "This is Underlined Firebrick Red text.")"
    echo "git_strong_gray: $(git_strong_gray "This is Strong Gray text.")"
    echo "git_strong_gray_light: $(git_strong_gray_light "This is Light Gray text.")"
    echo "git_strong_gray_dark: $(git_strong_gray_dark "This is Dark Gray text.")"
    echo "git_strong_gray_bold: $(git_strong_gray_bold "This is Bold Strong Gray text.")"
    echo "git_strong_gray_light_bold: $(git_strong_gray_light_bold "This is Bold Light Gray text.")"
    echo "git_strong_gray_dark_bold: $(git_strong_gray_dark_bold "This is Bold Dark Gray text.")"
    echo "git_strong_gray_underline: $(git_strong_gray_underline "This is Underlined Strong Gray text.")"
    echo "git_strong_gray_light_underline: $(git_strong_gray_light_underline "This is Underlined Light Gray text.")"
    echo "git_strong_gray_dark_underline: $(git_strong_gray_dark_underline "This is Underlined Dark Gray text.")"
    echo "git_strong_white: $(git_strong_white "This is Strong White text.")"
    echo "git_strong_white_light: $(git_strong_white_light "This is Light White text.")"
    echo "git_strong_white_dark: $(git_strong_white_dark "This is Dark White text.")"
    echo "git_strong_white_bold: $(git_strong_white_bold "This is Bold Strong White text.")"
    echo "git_strong_white_light_bold: $(git_strong_white_light_bold "This is Bold Light White text.")"
    echo "git_strong_white_dark_bold: $(git_strong_white_dark_bold "This is Bold Dark White text.")"
    echo "git_strong_white_underline: $(git_strong_white_underline "This is Underlined Strong White text.")"
    echo "git_strong_white_light_underline: $(git_strong_white_light_underline "This is Underlined Light White text.")"
    echo "git_strong_white_dark_underline: $(git_strong_white_dark_underline "This is Underlined Dark White text.")"
}
