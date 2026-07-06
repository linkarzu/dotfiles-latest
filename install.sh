#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Linux)
    exec "$repo_dir/scripts/linux/arch/bootstrap.sh" "$@"
    ;;
  Darwin)
    exec "$repo_dir/scripts/macos/mac/bootstrap.sh" "$@"
    ;;
  *)
    echo "Unsupported OS: $(uname -s). This installer supports Arch Linux and macOS." >&2
    exit 1
    ;;
esac
