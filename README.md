# prline

One line of GitHub PR + CI state for the current branch, built for the Claude Code status line (or any prompt).

```
PR #42 open · changes requested · CI ✗ 2 failing (build, unit-tests)
PR #42 open · ✓ approved · CI ✓ 4
PR #42 draft · ⚠ conflicts · CI ● 2 running 3/5
no PR · CI ✓            (last workflow run on a branch without a PR)
```

Requires only `bash`, `git`, and an authenticated [`gh`](https://cli.github.com). It prints nothing outside a GitHub repo or on a detached HEAD.

## Install

```sh
~/src/prline/install.sh   # after cloning; symlinks into ~/.local/bin
```

Then add it to your status line script (`~/.claude/settings.json` → `statusLine.command`):

```sh
PR=$(prline)            # or: prline "$DIR" if your script already parses workspace.current_dir
if [ -n "$PR" ]; then echo -e "$PR"; fi
exit 0   # a non-zero exit makes Claude Code hide the whole status line
```

The status line only re-renders on session activity, so an idle session shows the last value until something happens.

## My PRs across GitHub (`--mine`)

```
PRs ✎ 2 (✓1 ●1) · 👀 2 +15 team · 💬 3
```

One line for the four GitHub "pull requests" tabs, cached the same way (`PRLINE_MINE_TTL`, default 180s, since it uses the search API):

| | Query | |
| --- | --- | --- |
| `✎` | open, non-draft, authored by me, touched in the last `PRLINE_MINE_DAYS` (30) | `✓` approved · `✗` changes requested · `●` waiting |
| `📌` | assigned to me, not mine | hidden when zero |
| `👀` | review requested of me directly | `+N team` for requests via a team I'm on |
| `💬` | involves me, excluding the buckets above, touched in the last `PRLINE_MINE_DAYS` | |

```sh
MINE=$(prline --mine)
if [ -n "$MINE" ]; then echo -e "$MINE"; fi
```

## How it works

`gh` takes ~1s, so it never runs in the foreground. Each call prints the cached line for the repo/branch, and if that line is older than `PRLINE_TTL` (default 60s) a background refresh runs under a lock. New branches show up after the first refresh. Cache lives in `${XDG_CACHE_HOME:-~/.cache}/prline`.

| Env | Default | |
| --- | --- | --- |
| `PRLINE_TTL` | `60` | seconds before a background refresh |
| `PRLINE_MINE_TTL` | `180` | seconds before a background refresh of `--mine` |
| `PRLINE_MINE_DAYS` | `30` | `--mine` ignores authored/involved PRs untouched longer than this |
| `PRLINE_NO_COLOR` | unset | `1` disables ANSI colors |

`prline --refresh [dir]` and `prline --mine --refresh` fetch synchronously (handy right after `git push`).

## Development

Output is rendered by a jq program run through `gh --jq` (gh bundles gojq, so no `jq` at runtime). `test/run.sh` renders `test/fixtures/*.json` offline with `jq` and diffs against `test/expected.txt`; `test/run.sh --update` regenerates it.

## License

MIT. See [LICENSE](LICENSE).
