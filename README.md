# kikit

kiki-ki's working kit.

## Install

```sh
/plugin marketplace add kiki-ki/kikit
/plugin install kikit@kikit
```

## Plugins

| Plugin | Description |
|---|---|
| [kikit](plugins/kikit) | Working principles and task skills for coding agents |

## Development

Bump `version` in the plugin's `.claude-plugin/plugin.json` in every PR that changes the plugin. Installed copies update only when the version changes, and CI fails the PR without a bump.

Run `pnpm install` and `pnpm run check` to run the manifest, skill name, version and prose checks locally. CI also checks relative links and workflows.

## License

[MIT](LICENSE). Some skills are adapted from third-party work; each plugin's README lists their sources and licenses.
