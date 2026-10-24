#!/usr/bin/env bash
# Installs the api-migrations CLI for the biject GitHub Actions: the release binary of
# this repository for that version.
set -euo pipefail
version="${1:?usage: install-cli.sh <version>}"
repo="${BIJECT_CLI_REPO:-samirovsky/biject-actions}"
dest="${RUNNER_TOOL_CACHE:-$HOME/.local}/api-migrations/${version}"
mkdir -p "$dest"
if [ -x "$dest/api-migrations" ]; then
  echo "$dest" >> "$GITHUB_PATH"; exit 0
fi
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) target=x86_64-unknown-linux-gnu ;;
  Linux-aarch64) target=aarch64-unknown-linux-gnu ;;
  Darwin-arm64) target=aarch64-apple-darwin ;;
  Darwin-x86_64) target=x86_64-apple-darwin ;;
  *) echo "::error::api-migrations has no release binary for $(uname -s) $(uname -m)"; exit 1 ;;
esac
url="https://github.com/${repo}/releases/download/v${version}/api-migrations-${target}.tar.gz"
if ! curl -fsSL "$url" -o "$dest/cli.tar.gz"; then
  echo "::error::No api-migrations v${version} release binary at $url"
  exit 1
fi
tar -xzf "$dest/cli.tar.gz" -C "$dest" && rm "$dest/cli.tar.gz"
"$dest/api-migrations" --version
echo "$dest" >> "$GITHUB_PATH"
