# shellcheck shell=bash
#Dev: tput config file

blue() {
    tput setaf 4
    echo -n "$1"
    tput sgr0
}

red() {
    tput setaf 1
    echo -n "$1"
    tput sgr0
}

green() {
    tput setaf 2
    echo -n "$1"
    tput sgr0
}

yellow() {
    tput setaf 3
    echo -n "$1"
    tput sgr0
}

purple() {
    tput setaf 5
    echo -n "$1"
    tput sgr0
}

cyan() {
    tput setaf 6
    echo -n "$1"
    tput sgr0
}

blue_underlie() {
    tput setaf 4 
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

red_underlie() {
    tput setaf 1 
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

green_underlie() {
    tput setaf 2 
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

yellow_underlie() {
    tput setaf 3
    tput smul   
    echo -n "$1"
    tput sgr0   
}

purple_underlie() {
    tput setaf 5 
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

cyan_underlie() {
    tput setaf 6
    tput smul   
    echo -n "$1"
    tput sgr0
}

blue_bold() {
    tput setaf 4 
    tput bold    
    echo -n "$1" 
    tput sgr0    
}

red_bold() {
    tput setaf 1 
    tput bold    
    echo -n "$1" 
    tput sgr0    
}

green_bold() {
    tput setaf 2 
    tput bold    
    echo -n "$1" 
    tput sgr0    
}

yellow_bold() {
    tput setaf 3
    tput bold   
    echo -n "$1"
    tput sgr0   
}

purple_bold() {
    tput setaf 5 
    tput bold    
    echo -n "$1" 
    tput sgr0    
}

cyan_bold() {
    tput setaf 6
    tput bold   
    echo -n "$1"
    tput sgr0
}

blue_bold_underlie() {
    tput setaf 4 
    tput bold    
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

red_bold_underlie() {
    tput setaf 1 
    tput bold    
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

green_bold_underlie() {
    tput setaf 2 
    tput bold    
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

yellow_bold_underlie() {
    tput setaf 3
    tput bold   
    tput smul   
    echo -n "$1"
    tput sgr0   
}

purple_bold_underlie() {
    tput setaf 5 
    tput bold    
    tput smul    
    echo -n "$1" 
    tput sgr0    
}

cyan_bold_underlie() {
    tput setaf 6
    tput bold   
    tput smul   
    echo -n "$1"
    tput sgr0
}

print_styles() {
    echo "$(blue 'Blue text')"
    echo "$(red 'Red text')"
    echo "$(green 'Green text')"
    echo "$(yellow 'Yellow text')"
    echo "$(purple 'Purple text')"
    echo "$(cyan 'Cyan text')"
    echo "$(blue_underlie 'Blue underlined text')"
    echo "$(red_underlie 'Red underlined text')"
    echo "$(green_underlie 'Green underlined text')"
    echo "$(yellow_underlie 'Yellow underlined text')"
    echo "$(purple_underlie 'Purple underlined text')"
    echo "$(cyan_underlie 'Cyan underlined text')"
    echo "$(blue_bold 'Blue bold text')"
    echo "$(red_bold 'Red bold text')"
    echo "$(green_bold 'Green bold text')"
    echo "$(yellow_bold 'Yellow bold text')"
    echo "$(purple_bold 'Purple bold text')"
    echo "$(cyan_bold 'Cyan bold text')"
    echo "$(blue_bold_underlie 'Blue bold and underlined text')"
    echo "$(red_bold_underlie 'Red bold and underlined text')"
    echo "$(green_bold_underlie 'Green bold and underlined text')"
    echo "$(yellow_bold_underlie 'Yellow bold and underlined text')"
    echo "$(purple_bold_underlie 'Purple bold and underlined text')"
    echo "$(cyan_bold_underlie 'Cyan bold and underlined text')"
}