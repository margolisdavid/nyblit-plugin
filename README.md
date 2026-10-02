# Nyblit for Claude

Work with your Nyblit tasks, workflows and projects from Claude. This plugin gives Claude the same tools Nyblit's built-in assistant, Nyby, uses: reading your tasks, today's plan, workflows, projects and repeating templates, and creating, editing, moving, archiving and deleting them. It also teaches Claude how Nyblit organises work, so it uses those tools the way the app expects.

Nyblit is a task app for Mac, iPhone, iPad and Apple Watch: <https://www.nyblit.app>

## Requirements

- A Mac with Nyblit installed from the [Mac App Store](https://apps.apple.com/app/id6752837986).
- Claude Code, or Cowork in the Claude desktop app, running on that Mac. The connector is local to the Mac, so in claude.ai chat only the skill loads and the tools do not.
- Task Access for MCP turned on in Nyblit, under **Settings > AI Settings > Task Access for MCP**. Everything is off until you switch it on, and each switch (View Tasks, View Workflows, Create Tasks, Edit Tasks, Delete Tasks and so on) decides which tools Claude is given. These switches are separate from the ones that govern Nyblit's own assistant.

## Install

**From Anthropic's directory.** In claude.ai or the Claude desktop app, open **Customize > Plugins > Discover**, search for Nyblit and add it. It then also loads in your Claude Code sessions as a synced plugin.

**From Claude Code directly.**

```bash
claude plugin marketplace add margolisdavid/nyblit-plugin
claude plugin install nyblit@nyblit-plugin
```

Then start a new session and ask Claude about your tasks. The first Nyblit tool call starts Nyblit if it is not already running.

## What the plugin contains and runs

- `skills/nyblit/SKILL.md`: instructions that tell Claude when to use Nyblit and how its tabs, workflows, states and steps fit together.
- `server/nyblit-mcp.sh`: a shell script that Claude runs as `bash server/nyblit-mcp.sh` to start the `nyblit` MCP server. It looks for `Nyblit.app` in `/Applications`, then `~/Applications`, then asks LaunchServices. It then copies the connector binary out of `Nyblit.app/Contents/Resources/Nyblit.mcpb`, the MCP Bundle that Nyblit itself offers under Settings for Claude Desktop, into the plugin's data folder (`$CLAUDE_PLUGIN_DATA`, or `~/Library/Caches/nyblit-plugin` when that is not set), refreshes that copy whenever Nyblit updates, and hands over (`exec`) to it. The plugin bundles no binary of its own, so the connector always matches the installed app.
- Nyblit also ships a second copy of the connector beside its executable, at `Nyblit.app/Contents/MacOS/nyblit-mcp`. That copy is sandboxed, as the Mac App Store requires, and a sandboxed executable cannot be started directly by another process, which is why the plugin uses the bundle instead.
- The connector speaks MCP over stdin and stdout and relays each request to the running Nyblit app over a Unix socket inside Nyblit's app-group container, `~/Library/Group Containers/group.com.margoliswatch.yodo.shared/mcp.sock`. It launches Nyblit if it is not running. The app answers from its own local database.
- `icon.png`, this README, the `LICENSE`, and the manifests in `.claude-plugin/`.

The plugin makes no network requests and sends nothing anywhere. The only thing it writes is that cached copy of Nyblit's own connector. Nothing leaves your Mac through it. Whatever Nyblit itself syncs, such as iCloud or Nyblit Cloud if you have turned them on, is governed by Nyblit's own privacy policy, linked below.

## Privacy Policy

The plugin collects no data. Everything Claude reads or changes through it stays in the Nyblit app on your Mac, under the permissions you set in Nyblit's AI Settings. Changes Claude makes are applied in Nyblit immediately, without a confirmation card in the app, which is why the skill tells Claude to confirm with you first. Nyblit's privacy policy covers the app and its optional sync services: <https://www.nyblit.app/privacy-policy>. Questions go to the support page below.

## Troubleshooting

- **"Nyblit is not installed on this Mac."** Install Nyblit from the Mac App Store, then start a new session.
- **Nyblit tools are missing or fewer than expected.** Check the switches under Settings > AI Settings > Task Access for MCP in Nyblit, then start a new session.
- **Nothing happens on Linux or Windows.** The connector is Mac only. Claude Code lists the failed server under `/plugin` > **Errors**, and the skill still loads.

## Support

<https://www.nyblit.app/support>

## License

This plugin is released under the MIT License (see `LICENSE`). Nyblit itself is a separate, proprietary application.
