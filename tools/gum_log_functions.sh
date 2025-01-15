#!/bin/bash

gum_log_debug() {
    gum log --structured --time TimeOnly --level debug "$@"
}

gum_log_info() {
    gum log --structured --time TimeOnly --level info "$@"
}

gum_log_warning() {
    gum log --structured --time TimeOnly --level warn "$@"
}

gum_log_error() {
    gum log --structured --time TimeOnly --level error "$@"
}

gun_log_fatal() {
    gum log --structured --time TimeOnly --level fatal "$@"
}