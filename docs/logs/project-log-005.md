# Project Log 005 — Build Steps 1–3: the gray-box slice walks and talks

*25–27 October 2026 · Noraebang Night · Episode 1 · Act 1: 국민학교 시대*
*Previous logs: 004 (25 Oct), 003, 002, 001*

> **Read this first in every new session.** Then Log 004 for anything this log doesn't change, then 003–001, then the documents in §2.
> Markers: ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

---

## 0. Summary

- **The game is playable.** Gray-box Map 01 (13 rooms), lane walking, doors, random spots with traps and pickups, the HUD, death, and Scenes 01–02 with choices, the walk home with 현정, and three Saturday optional conversations. Saturday → Monday → end card.
- Build Steps **1, 2a, 2b, HUD icons, 3a, 3b, 3c** done. 903 headless checks pass. All Korean in the game is verbatim from the approved scripts.
- The user played Steps 2a–3b by hand and approved them. Next build step is **Step 4: the fight player**.
- **Character design** starts in a separate session (CHAT/WRITE), reading this log.

---

## 1. Workflow rules (additions)

| # | Rule |
|---|---|
| 16 | **Short Claude Code prompts.** Quality, not quantity. Only what Claude Code needs. |
| 17 | **Split big build steps** (2 → 2a/2b, 3 → 3a/3b/3c). Each part is tested, played by the user, and committed before the next. |
| 18 | **Screenshots go in the repo** at `tests/shots/` (git-ignored), never in hidden user folders. |
| 19 | **Scripts are built from files in `docs/scripts/`.** Claude Code copies Korean verbatim and stops if the source file is missing. A test checks every Korean line against the doc. |
| 20 | Claude Code prompts give the Godot path for the machine they run on (see §6). |
| 21 | Approved scripts are filed straight away (Log 003 rule 11 still applies). |

---

## 2. Document map (current)

| Document | Where | Status |
|---|---|---|
| Roadmaps (Master, Episode 1, Act 1), DDEOK Master Roadmap | `docs/roadmaps/` / Project | Frozen |
| Systems Spec v0.4 | `docs/design/` | **Current**, with Log 004 §3 overrides and §4 below |
| Style Brief v0.3 | `docs/design/` | Current |
| Song Sheet 01 v0.2 〈달님은 계란 후라이〉 | `docs/songs/` | Current |
| Scene 01 script v0.1, Scene 02 script v0.1 | `docs/scripts/` | **Superseded** |
| **Scene 01 script v0.2** | `docs/scripts/` + Project `claude/` | **Current** (approved 26 Oct) |
| **Scene 02 script v0.2** | `docs/scripts/` + Project `claude/` | **Current** (approved 26 Oct) |
| **Optional Conversations — Saturday v0.1** | `docs/scripts/` + Project `claude/` | **Current** (approved 26 Oct) |
| `CLAUDE.md` (repo root) | Untracked | Claude Code's own notes: launch args, architecture. Scrub personal `C:\Users\...` paths before tracking |
| Project Logs 001–005 | Project | Logs 003–005 not yet in `docs/logs/` |

---

## 3. What was built

| Step | Commit | Contents |
|---|---|---|
| 1 | `72e4604` | Godot 4.7.2 + Forward+ (Vulkan, Arc B580 confirmed), 1920×1080, input map, Noto Sans KR (OFL, variable, 10 MB), fog test stage, **GameState v0.4** (hearts in halves, 눈치 cap 7 + overflow → DDEOK, secrets/knowers/one-hop leaks, fight snapshot, death reset, versioned atomic saves with `.bak` and v0 → v1 migration), build 001 moved to `legacy/` (`.gdignore`), headless test runner |
| 2a | `f4f69a0` | Player with **3 lanes** (W/S), 12-room gray-box Map 01 from a JSON registry, doors with fade, locked-door flag, fixed per-room camera following on X, interaction |
| 2b | `a784aba` | Spot dealer (pure function, per-seed, per-map-day budget, anti-farming), traps with red flash, DDEOK/notes/health pickups, HUD, game-over and death reset, autosave on room change |
| HUD | `80cb78e` | 7 squinting-eye 눈치 icons (iris right), 송편 DDEOK icon, `--hearts N` |
| 3a | pushed | Dialogue box (W/S + Enter, effect cues), scene director, **Scene 01** (`scene_01.dialogue`), placeholder actors, 10-second / proximity trigger, Saturday roam, day change with title card, 2층 locked Sat / open Mon, progress steps and resume, `--skip-to` |
| — | `ac4b872` | `.gitignore` for `tests/shots/` |
| 3b | pushed | **Scene 02** with the 02-D form panel and taunts, 현정 following across rooms, 현관/교문/전파사 TV triggers, 문방구 unlock, 집 exit, end card; **three Saturday optional conversations**; speaker aliases; F9 / `--no-labels` dev-label toggle; room titles removed; Scene 01 pacing tunables; compact dialogue panel |
| 3c | **commit pending** | "Enter" keycap above the nearest interactable (nothing above 보람); desk moved off the classroom door + door-clearance test for every room; **빈 교실** (13th room) off the 2층 복도; gray era props in sparse rooms and the 문방구; import fix (`UPDATE_TRANSLATION_TEMPLATES_AUTOMATICALLY=false`) with a byte-identical `project.godot` test; stale-`.dialogue`-import test |

**Progress steps:** `scene_01` → `sat_roam` → `scene_02` → `mon_walk` → `mon_roam` → `sat2_pending` (end card).
**Dev args (after `--`):** `--new-game`, `--seed N`, `--hearts N`, `--skip-to scene_01|sat_roam|scene_02|mon_walk|mon_roam` (`mon` = alias), `--no-labels`, capture modes `--capture`, `--capture-map`, `--capture-hud`, `--capture-dialogue`, `--capture-alley`, `--capture-rooms`. F9 toggles dev labels.

---

## 4. Decisions and deviations (spec v0.5 candidates)

| # | Decision | Deviates from |
|---|---|---|
| 1 | **Depth uses 3 lanes** (z −3.0, −4.5, −6.0; count in `tuning.json`) | Spec §4.5 (free W/S) |
| 2 | **Enter uses doors; W/S are lanes only** | Spec §4.5 / Log 003 #5 (W/S doors) |
| 3 | Interaction ignores lanes; the keycap shows the nearest interactable only | — |
| 4 | **Props aren't solid** (❓ revisit with art) | — |
| 5 | **Both shops hang off the 골목길** (not a chain) | Spec §3.7 diagram |
| 6 | **빈 교실** built as its own room off the 2층 복도, scenery only | Spec §3.7 (implied) |
| 7 | Health items apply **instantly on pickup** (❓ tune after playing) | Spec §2.1 (silent) |
| 8 | Per map-day deal: 2 DDEOK (1 each), 1 extra (note 2 · 반창고 2 · 빨간약 1), 2 traps; ½-heart traps weighted 8:1 (≈80%) | Spec §3.3 starting point |
| 9 | Invented trap: **깨진 유리창** on the 2층 landing, 1 heart. 화장실 ghost is a plain 1-heart trap for now | Spec §3.7 trap list |
| 10 | **전파사 뒤** spot is Monday-only (Saturday ends at the alley) | — |
| 11 | Saturday ends at the **교문 → 골목길** door; Monday ends at a new **집** exit at the far right of the 골목길 | — |
| 12 | New game and death restart at **Scene 01 (01-A)**; Scene 00 not built | Log 004 #4 (as intended) |
| 13 | Autosave: room changes, scene starts, roam starts, after death reset. Launch resumes at the **start** of the saved progress step | — |
| 14 | 상훈 (반장) knower id = `banjang` (as in Log 001) | — |
| 15 | Speakers shown as 미숙 / 미경 in game (alias table); script text keeps 손미숙 / 손미경 | Scene 02 v0.2 table |
| 16 | Dev labels on props and actors stay during development; **no names over characters in the final build** ✅ (user) | — |
| 17 | Room titles are gone ✅. Final build uses **natural signs** (classroom plates etc.), not floating text ✅ (user) | — |
| 18 | **Assassination stays on the evening of 26 Oct** (history). News reached people on the 5am radio and the 7:25am statement on 27 Oct, so the Saturday-morning mourning broadcast is accurate ✅ | — |

---

## 5. Open (defaults in brackets)

1. Placeholder card id **`hyunjeong_mom`** (Boss 3's id not named in the spec).
2. **Checkpoint vs Scene 00:** does a death keep Scene 00's results? *(no; decide at the Scene 00 rebuild)*. The 01-A3 "자존심 lost in Scene 00" line is kept and can't fire yet.
3. **"오늘도 만화 안 해?"** kept; 🟡 "오늘은" suggested — raise at native-speaker review.
4. 🔍 **가정통신문** in 1979 (OC-03) — not verified. 🔍 풍금 and 국민교육헌장 frame — seen in 1970s school photo galleries only.
5. Placeholder text: optional-conversation **repeat lines**, **END OF BUILD 3b** card, 02-B continuity (1A "meet at the 문방구" yet 현정 walks with 보람 — accepted).
6. 송편 seam ticks faint *(fix with the Inkscape HUD art)*.
7. 3D dev labels still overlap in crowded scenes *(dev-only, ignore)*.
8. `save_game()` can overwrite a save from a newer version (load refuses; autosave is turned off in that case — check).
9. `data/secrets/act1_cards.json` now used for card display names ✅ (was flagged unused).
10. Everything in Log 004 §7 still open (amounts, prices, skills, clothes, fight damage, restarts limit, music tool, ComfyUI, final font, shared save).

---

## 6. Repo and machines

- **Commit identity:** `3th4n` + `273777105+eth4nh4rdy@users.noreply.github.com`, repo-level config on **both** machines.
- **Remote:** `https://github.com/You-Can-t-Speak-Korean/noraebang-night-ep1.git` (laptop updated from the old `eth4nh4rdy` URL).
- **Laptop incident (26 Oct):** it held the 2 **pre-rewrite** commits with personal emails. Reset to `origin/main`; **never push old commits from any clone**.
- **Windows PC:** `C:\Users\smeefer\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`. F5 in the editor doesn't work (use ▶ or the command line). F1/F2 need Fn.
- **CachyOS laptop:** `godot` on PATH (`4.7.2.stable.arch_linux`). After pulling, run `godot --headless --path . --import` once, or the stale-import test fails.
- **To replay from the start:** add `-- --new-game --seed 1`.
- **Housekeeping still to do:** commit 3c; scrub and commit `CLAUDE.md`; add Logs 003–005, Spec v0.2–v0.4, Style Brief v0.2–v0.3 and the DDEOK roadmap to `docs/` if not already there; fix `LICENSE-ASSETS.md` and `README.md` (Galmuri → Noto Sans KR, OFL entry) — the user asked to keep these out of game-dev prompts; Project file duplicates (root vs `claude/`).

---

## 7. Next steps

1. **Commit 3c** (git block given 27 Oct; check `git diff project.godot` shows only the one setting).
2. **Character design session** (separate, CHAT/WRITE): reads this log and Style Brief v0.3.
3. **DEV Step 4 — fight player:** song JSON (Song Sheet 01 v0.2), the reality freeze, cross-outs, dodges, loaded blanks, both win types, game over, restarts. Likely split 4a/4b.
4. Step 5 — 문방구 and DDEOK spending. Step 6 — Boss 1 party pre-fight map. Later — Scene 00 rebuilt in 3D.
5. WRITE when needed: Monday optional conversations, repeat lines, the news-anchor game-over text.
