#!/usr/bin/env bash

set -eEuo pipefail
trap 's=$?; echo "$(date "+%Y-%m-%d %H:%M:%S") $0: $BASH_COMMAND error on line $LINENO with exit code $s" >&2; exit $s' ERR

MACOS="🍏 macOS"
LINUX="🐧 Linux"
WINDOWS="🪟 Windows"
UNKNOWN="❓ Unknown"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEBUG=${DEBUG:-false}
PACKAGES=${PACKAGES:-$1}

log() {
  local level="$1"
  local message="$2"
  case "$level" in
    DEBUG) [ "$DEBUG" = true ] && echo -e "🐞 $message" >&2 ;;
    INFO) echo -e "ℹ️ $message" ;;
    WARNING) echo -e "⚠️ $message" >&2 ;;
    ERROR) echo -e "❌ $message" >&2 ;;
    SUCCESS) echo -e "✔  $message" ;;
    *) echo -e "🚫 Unknown log level: $level" >&2 ;;
  esac
}

debug() { log "DEBUG" "$*"; }
info() { log "INFO" "$*"; }
warn() { log "WARNING" "$*"; }
error() { log "ERROR" "$*"; }
success() { log "SUCCESS" "$*"; }
panic() {
  error "$1"
  exit "${2:-1}"
}

installing() {
  local message="$1"
  echo -e "📥 Installing $message..."
}

handle_error() {
  local lineno="$1"
  local cmd="$2"
  local exit_code="$3"

  error "$(date +'%Y-%m-%d %H:%M:%S') [$0] Error:"

  case $exit_code in
    1) warn "Incorrect command: '$cmd' failed at line $lineno." ;;
    127) warn "Command not found: '$cmd' at line $lineno." ;;
    *) warn "Unexpected error: '$cmd' failed at line $lineno with exit code $exit_code." ;;
  esac

  exit "$exit_code"
}

detect_os() {
  case "$OSTYPE" in
    darwin*) echo -e "$MACOS";;
    linux-gnu*) echo -e "$LINUX";;
    msys*|cygwin*|win32*) echo -e "$WINDOWS";;
    *) echo -e "$UNKNOWN OS";;
  esac
}

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    installing "Homebrew 🍻 (requires admin privileges)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_chocolatey() {
  if ! command -v choco &>/dev/null; then
    installing "Chocolatey (requires admin privileges)"
    powershell -NoProfile -ExecutionPolicy Bypass -Command \
      "Set-ExecutionPolicy Bypass -Scope Process -Force; \
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; \
      iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
  fi
}

install_scoop() {
  if ! command -v choco &>/dev/null; then
  installing "Scoop (does not require admin privileges)"
  powershell -NoProfile -ExecutionPolicy Bypass -Command \
    "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; \
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))"
  fi
}

apt_install() {
  installing " $* on $LINUX (requires sudo)"
  sudo apt-get install -y "$@"
}

brew_install() {
  installing " $* on $MACOS via Homebrew"
  brew install "$@"
}

scoop_install() {
  installing " $* on $WINDOWS via Scoop"
  scoop install "$@"
}

choco_install() {
  installing " $* on $WINDOWS via Chocolatey"
  choco install -y "$@"
}

install_on_mac() {
  install_homebrew
  brew_install "$@"
}

install_on_linux() {
  sudo apt-get update
  apt_install "$@"
}

install_on_windows() {
  install_scoop || install_chocolatey
  scoop_install "$@" || choco_install "$@" || {
    panic "Unable to install dependencies on Windows." >&2
  }
}

install () {
  case "$os" in
    "$MACOS")
      install_on_mac "$@"
      ;;
    "$LINUX")
      install_on_linux "$@"
      ;;
    "$WINDOWS")
      install_on_windows "$@"
      ;;
    *)
      error "Cannot install $* on $UNKNOWN ($os). Please install it manually."
      ;;
  esac
}

install_dependencies() {
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      warn "Missing command: $cmd" >&2
      install "$cmd"
    fi
  done
}

update_bash() {
  local os
  os=$(detect_os)

  echo -e "⬆️ Updating Bash..."

  case "$os" in
    "$MACOS")
      install_on_mac bash
      ;;
    "$LINUX")
      install_on_linux bash
      ;;
    *)
      info "No Bash update required for $os 😊"
      ;;
  esac
}

main() {
  local os
  os=$(detect_os)
  echo -e "💻 Detected system: $os"

  install_dependencies $PACKAGES

  if ((BASH_VERSINFO[0] < 4)); then
    echo -e "🔄 Updating Bash to version 4+..."
    update_bash
  fi

  echo -e "✅ All dependencies installed"
  echo -e "📌 Bash version: $(bash --version)"
}

main "$@"
