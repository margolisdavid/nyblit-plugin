#!/bin/bash
#
# Starts Nyblit's MCP connector for Claude.
#
# This plugin ships no server of its own. Nyblit, installed from the Mac App
# Store, carries its MCP connector (nyblit-mcp) inside the app bundle, packed
# in Nyblit.mcpb: the same MCP Bundle the app offers under Settings for Claude
# Desktop to install. The connector speaks MCP over stdin and stdout and relays
# each request to the running app over a Unix socket inside Nyblit's own
# container, launching the app first if it is not running.
#
# This script finds the installed app, copies the connector out of that bundle
# into the plugin's data folder (refreshing it whenever Nyblit updates), and
# hands over to it, so the connector always matches the installed app.
#
# Why not simply run Nyblit.app/Contents/MacOS/nyblit-mcp: that copy is
# sandboxed, as the App Store requires of every executable in the bundle, and
# a sandboxed executable started directly by another process cannot enter its
# sandbox and dies before main(). The copy inside Nyblit.mcpb is the one built
# to run outside the app.
#
# Nothing here reaches the network.

set -eu

bundle_id="co.margoliswatch.YoDo"   # Nyblit's bundle identifier
app_name="Nyblit.app"

fail() {
    echo "nyblit: $*" >&2
    exit 1
}

if [[ "$(uname -s)" != "Darwin" ]]; then
    fail "Nyblit's connector runs only on macOS, alongside the Nyblit app."
fi

# The usual install locations first, then LaunchServices for anywhere else.
app=""
for candidate in "/Applications/$app_name" "$HOME/Applications/$app_name"; do
    if [[ -d "$candidate" ]]; then
        app="$candidate"
        break
    fi
done
if [[ -z "$app" ]]; then
    app="$(osascript -e "POSIX path of (path to application id \"$bundle_id\")" 2>/dev/null || true)"
    app="${app%/}"
fi

if [[ -z "$app" || ! -d "$app" ]]; then
    fail "Nyblit is not installed on this Mac. Install it from the Mac App Store: https://apps.apple.com/app/id6752837986"
fi

bundle="$app/Contents/Resources/Nyblit.mcpb"
if [[ ! -f "$bundle" ]]; then
    fail "The installed Nyblit ($app) has no MCP connector. Update Nyblit from the Mac App Store."
fi

# One copy of the connector per installed bundle, keyed by the bundle's hash so
# an app update is picked up on the next start and nothing is re-extracted
# otherwise. CLAUDE_PLUGIN_DATA survives plugin updates; the Caches fallback
# covers hosts that do not set it.
data="${CLAUDE_PLUGIN_DATA:-$HOME/Library/Caches/nyblit-plugin}"
connector="$data/nyblit-mcp"
stamp="$data/nyblit-mcp.sha256"
digest="$(shasum -a 256 "$bundle" | cut -d ' ' -f 1)"

if [[ ! -x "$connector" || ! -f "$stamp" || "$(cat "$stamp")" != "$digest" ]]; then
    mkdir -p "$data"
    scratch="$(mktemp -d "$data/extract.XXXXXX")"
    unzip -q -o "$bundle" server/nyblit-mcp -d "$scratch"
    chmod +x "$scratch/server/nyblit-mcp"
    mv -f "$scratch/server/nyblit-mcp" "$connector"
    printf '%s\n' "$digest" > "$stamp"
    rm -rf "$scratch"
fi

exec "$connector"
