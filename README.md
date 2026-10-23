# 노래방 나이트 · Noraebang Night

**Episode 1, Act 1: 국민학교 시대** — a satirical horror-survival Korean language game by Korean language education organization, **<니가 한국어 못해>**.

1979. 장보람 is seven, the President's head was blown off on live melody last night, and nobody in her classroom cares. Survive school one Noraebang Night at a time.

> Contains extreme cartoon violence. No sexual content.

## Status

Pre-alpha. Built so far: the opening scene (assassination → title → classroom → first choice) with placeholder art. See `docs/logs/` for what's built and what's next.

## Run it

1. Install **Godot 4.7.1** (or any 4.6+) from godotengine.org.
2. Open this folder in Godot, or run `godot --path .` from the command line.
3. Click or tap to advance; tap a button to choose.

## Tests

```
godot --headless --import                     # first time only
godot --headless -s res://tests/test_runner.gd
```

The tests play every branch of each dialogue scene and check the writer's rule: every choice does exactly one thing (+1 눈치, −1 비밀 card, or nothing).

## How the project is organised

```
data/dialogue/   .dialogue scripts (Dialogue Manager format) — writers edit these
data/songs/      song files (JSON) — coming with the 김은주 fight
data/secrets/    secret-card definitions per Act
scripts/         GameState (눈치, 비밀, hearts) and loaders
scenes/          Godot scenes: opening, dialogue box, HUD
art/ audio/      assets (placeholders for now)
docs/roadmaps/   original plans — never modified
docs/design/     production specs — new version = new file
docs/songs/      song sheets
docs/logs/       project logs — what was actually built
tests/           headless tests and a screenshot tool
```

**Principle:** scenes and songs are data, code runs any of them. A new scene is a new `.dialogue` file; its stage directions (`$> stage("classroom")`) call methods on the scene that plays it.

## Licence

- **Code:** GNU AGPL v3.0 or later — see `LICENSE`.
- **Story, script, songs, music, art, characters, docs:** all rights reserved — see `LICENSE-ASSETS.md`.
- Third-party: Dialogue Manager (MIT), Galmuri font (OFL 1.1).
