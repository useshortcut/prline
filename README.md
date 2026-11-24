# pr-state

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
~/src/pr-state/install.sh   # after cloning; symlinks into ~/.local/bin
```

Then add it to your status line script (`~/.claude/settings.json` → `statusLine.command`):

```sh
PR=$(pr-state)            # or: pr-state "$DIR" if your script already parses workspace.current_dir
[ -n "$PR" ] && echo -e "$PR"
```

The status line only re-renders on session activity, so an idle session shows the last value until something happens.

## How it works

`gh` takes ~1s, so it never runs in the foreground. Each call prints the cached line for the repo/branch, and if that line is older than `PR_STATE_TTL` (default 60s) a background refresh runs under a lock. New branches show up after the first refresh. Cache lives in `${XDG_CACHE_HOME:-~/.cache}/pr-state`.

| Env | Default | |
| --- | --- | --- |
| `PR_STATE_TTL` | `60` | seconds before a background refresh |
| `PR_STATE_NO_COLOR` | unset | `1` disables ANSI colors |

`pr-state --refresh [dir]` fetches synchronously (handy right after `git push`).

## Development

Output is rendered by a jq program run through `gh --jq` (gh bundles gojq, so no `jq` at runtime). `test/run.sh` renders `test/fixtures/*.json` offline with `jq` and diffs against `test/expected.txt`; `test/run.sh --update` regenerates it.
