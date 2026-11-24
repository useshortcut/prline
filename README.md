# prline

One-line GitHub PR status for the Claude Code status line (or any prompt): the current branch's PR and CI, and with `--mine`, a summary of every open PR waiting on you across GitHub.

```
PR #42 open · changes requested · CI ✗ 2 failing (build, unit-tests)
PR #42 open · ✓ approved · CI ✓ 4
PR #42 draft · ⚠ conflicts · CI ● 2 running 3/5
no PR · CI ✓            (last workflow run on a branch without a PR)
```

Requires only `bash`, `git`, and an authenticated [`gh`](https://cli.github.com). The per-branch line prints nothing outside a GitHub repo or on a detached HEAD; `--mine` works from any directory.

## Install

```sh
git clone https://github.com/useshortcut/prline.git
prline/install.sh          # symlinks bin/prline into ~/.local/bin (or the directory you pass); run it from anywhere
```

Then add it to your status line script (`~/.claude/settings.json` → `statusLine.command`). Each mode prints one line, or nothing, so `${VAR:+ | $VAR}` appends it to an existing line without a dangling separator:

```sh
PR=$(prline "$DIR")      # $DIR from workspace.current_dir in the status line's JSON input
MINE=$(prline --mine)
echo -e "📁 ${DIR##*/}${PR:+ | $PR}"
echo -e "⏱️ ${MINS}m${MINE:+ | $MINE}"
exit 0   # a non-zero exit makes Claude Code hide the whole status line
```

```
📁 my-repo | PR #42 open · ✓ approved · CI ✓ 4
⏱️ 12m | PRs ✎ 2 (✓1 ●1) · 👀 2 +15 team · 💬 3
```

Call it by full path if `~/.local/bin` might not be on the status line's PATH.

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

A fetch takes 1–3s (`gh pr view` for a branch, one GraphQL search call for `--mine`), so it never runs in the foreground. Each call prints the cached line and, if it is older than its TTL, starts a background refresh under a lock. The per-branch line is cached per repo and branch, so new branches show up after their first refresh; `--mine` is a single cache entry shared by every directory. Cache lives in `${XDG_CACHE_HOME:-~/.cache}/prline`.

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
