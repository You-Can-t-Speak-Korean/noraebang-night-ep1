# Noraebang Night Ep1 Project Log 006 — Build Step 4: the fight player

*27 October – 6 November 2026 · Noraebang Night · Episode 1 · Act 1: 국민학교 시대*
*Previous logs: 005 (27 Oct), 004, 003, 002, 001*

> **Read this first in every new session.** Then read Logs 005, 004, 003, 002 and 001 **in full** for anything this log doesn't change, then the documents in §2.
> Markers: ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

---

## 0. Summary

- **Build Step 4 is done.** The fight player runs 〈달님은 계란 후라이〉 on the real Suno track, sung by 보람.
  - Freezes land on the blank words. A wrong answer skips the word and screams.
  - Cross-outs, loaded blanks, both win types, game over and retry all work.
  - The results page appears after the last sung line, and the track plays out underneath it.
- Built as 4a, 4b, a cleanup, 4c-a (plus a fix round), 4c-b and 4c-c (plus a fix round). **1414 headless checks pass**, with 10 clean runs at the end.
- **User playtest: PASS** (6 Nov).
- **Song timing workflow** ✅: blanks are timed in the game with `--mark-song` (hold Space through each blank word). The user wants to keep it for every boss song (§4).
- **Native-speaker review passed** (6 Nov) for: 「적어요」, the three loaded-blank taunts, and the intro wording.
- **Three screams** now exist in `audio/sfx/` but are not integrated yet.
- **Next:** integrate the screams → Song Sheet 01 v0.3 → the next song sheet template version → Step 5 (문방구) / Step 6 (party map).

---

## 1. Workflow rules (additions)

| # | Rule |
|---|---|
| 22 | **Read every log in the chain in full at session start** (001 → latest). In this session Claude skipped 001–003 at first; the user flagged it. |
| 23 | **Claude doesn't raise legal rights or licensing of the user's own tools and assets.** That is the lawyer's job (user, 28 Oct). Claude is the developer and writer. |
| 24 | **Song timing is measured in the game with `--mark-song`, never by hand transcription** ✅ (user, 6 Nov: "keep this workflow"). |
| 25 | Tests that check timing **read expected values from the labels file**; no hard-coded times. A test must be able to fail on the bug it guards (several early timing tests couldn't). |
| 26 | Input features are tested **through the real input path** (`Input.parse_input_event` with the real UI up), not by calling the logic directly. |
| 27 | Tests, captures and `--fight-auto` runs use the **sandbox save** (`user://sandbox/`), never the real save. |
| 28 | Log naming ✅ (user): title **"Noraebang Night Ep1 Project Log 00N"**, filename **`noraebang-night-ep1_project-log00N.md`**. |

---

## 2. Document map (changes since Log 005)

| Document | Where | Status |
|---|---|---|
| Song Sheet 01 v0.2 〈달님은 계란 후라이〉 | `docs/songs/` | Current but **stale** (see §6.2). v0.3 next |
| **Song Sheet Template v0.1** | Project (`song-sheet-template-v0.1.md`, duplicated at root) | Current. One template, one sheet per song. Next version planned (§6.3) |
| **`data/songs/eunju_dalnim_boram.labels.txt`** | Repo | **The live timing source** (Audacity label format). Written by `--mark-song` / `--check-song` |
| `docs/backups/eunju_dalnim_boram.labels.txt` | Repo (untracked) | **The user's original hand transcription. Keep untouched** ✅ |
| `docs/songs/eunju_dalnim_boram.labels.txt` | Repo (untracked) | Claude's 1 Nov conversion of the original. Superseded by the `data/songs/` copy |
| `audio/songs/dalnim_boram.mp3` | Repo | The game track (보람 sings) |
| `달님은 계란 후라이_김은주.mp3`, `…_함현정.mp3` | `audio/songs/` (untracked) | Other Suno versions. Unused |
| `audio/sfx/scream1.mp3` (short), `scream2.mp3` (long), `scream3.mp3` (mid) | Repo (new) | Not integrated yet |
| `art/characters/boram_1979_school.png`, `boram_concept_art.png` | Repo (untracked) | From character design work. Not part of Step 4 |
| `docs/logs/project-log-005.md` | Repo (untracked) | Not committed yet |

---

## 3. What was built

| Step | Status | Contents | Checks |
|---|---|---|---|
| **4a** | Pushed (hash not recorded) | `data/songs/eunju_dalnim.json` generated from the sheet (`tools/build_song.gd`, `tools/song_sheet.gd`). Song clock interface + silent clock. Gray-box fight room with the 반주기 panel. Freeze with a 5 s creep. 3 shuffled options (seeded). −1 heart per miss. 점수. Revenge and survival wins. 문태식 game over. Retry from the fight-start snapshot. Autosave at fight start. `--fight eunju`, `--fight-auto`, `--capture-fight` | 1098 |
| **4b** | Pushed | Sandboxed saves. Cross-outs (X or click a 눈치 eye; removes a seeded wrong option). Loaded blanks with a flourish. Taunts parsed from the sheet. Aftermath (survival line + taunts). Phase lighting data. `--nunchi`, `--known`, `--fight-auto cross` | 1174 |
| Cleanup | Pushed | `fight_lighting_effects` off by default. Cross-out hint moved below the lyric panel. Keycap test deflaked | 1178 |
| **4c-a** | In the 4c git block | `scripts/song_labels.gd` (parse / serialize / apply, marker rule). `scripts/audio_song_clock.gd` (Godot sync formula + `audio_offset`). Pause at `word_start − 0.05`. Right answer resumes; wrong answer seeks to `word_end` + scream. Intro and outro hidden on the panel. `--check-song` audition (nudges, P replay, N/B jumps, Ctrl+S). `--no-audio` | 1264 |
| 4c-a fix | In the 4c git block | No code bug: freezes verified on WASAPI within 20 ms of `pause_at`. `.gitignore` fixed | 1279 |
| **4c-b** | In the 4c git block | Labels applied **at load** (in memory). **`--mark-song` tap tool** (`song_tap.gd`, `song_tap_tool.gd`): 8-click calibration, hold Space per blank, 2–3 passes, preview, auto-save + JSON rebuild. Stale-JSON test. Parser hardening (tab runs, errors on bad lines). Space read in `_input` with physical keycode + focus handling. On-screen feedback. scene_02 death-restart and keycap tests fixed. Audition nudges keep 3 decimals | 1399 |
| **4c-c** | In the 4c git block | Results appear at the last sung line's end (`results_time()`). The track plays out under results / taunts / end card until the stream ends (`stops_at_length()`: false for audio). `first_line_pause` race fixed (`fetches_in_flight`). 신발장, `_search_spot` and keycap tests wait on conditions | 1414 |

**4c commit:** one git block covers 4c-a to 4c-c and includes the mp3 (given 6 Nov). ❓ Confirm it was pushed.

**Dev args (after `--`), new:**
- `--fight eunju`
- `--fight-auto right|wrong|mixed|cross`
- `--capture-fight`
- `--sandbox`
- `--nunchi N`
- `--known a,b,c`
- `--no-audio`
- `--check-song eunju`
- `--mark-song eunju`

**Tuning keys, new:**

| Key | Default | Notes |
|---|---|---|
| `fight_lighting_effects` | false | |
| `fight_audio` | true | |
| `audio_offset` | 0.0 | Positive values make events fire earlier |
| `blank_pause_lead` | 0.05 | |
| `blank_word_default_len` | 0.7 | |
| `song_first_line_time` / `song_line_gap` | — | Placeholder fallback when no labels file exists |

**Commands (Windows):**
- Godot: `& "C:\Users\smeefer\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path . -- <args>`
- Rebuild the song JSON: `… --headless --path . -s res://tools/build_song.gd`

---

## 4. Song timing workflow ✅ (keep for every boss song)

1. **Track.** The Suno track goes to `audio/songs/<song>_<singer>.mp3`, with an ASCII filename.
2. **Labels file.** `data/songs/<song>_<singer>.labels.txt` in Audacity label format: `start<TAB>end<TAB>text`.
   - Tags: `(intro)`, `(outro)` and `(skip)` mark timing-only lines; `[n] word` marks blank word n.
   - Other labels are lyric fragments. In file order, they must spell the sheet's lyric lines (only Hangul is compared).
   - Line times only drive the lyric scroll, so rough times are fine.
3. **`--mark-song <boss>`:**
   - Calibrate by tapping Space with 8 clicks.
   - For each blank, **hold Space while the word is sung**.
   - Listen to the preview, then press Enter to keep it, R to redo or B to go back.
   - Each kept blank saves the labels file and rebuilds the song JSON.
4. **`--check-song <boss>`** to listen to the whole fight (no damage), with nudge keys if needed.

**Why hand timing failed:**
- the marks were mostly on whole seconds;
- Audacity and Godot read the MP3 timeline differently (Godot reads the track as 125.37 s; the user's player showed 2:06);
- the game read times baked into the JSON, so edits to the labels didn't reach it. Labels are now applied at load.

---

## 5. Decisions and deviations (Spec v0.5 / Song Sheet v0.3 candidates)

| # | Decision | Deviates from |
|---|---|---|
| 1 | **보람 sings the game cut** ✅. 은주 speaks the intro (the track says 「다 조용히 해. 내 노래야.」, without the sheet's 「자,」; native review passed). The outro 「잘 먹겠습니다」 is spoken by 보람 and is in the audio | Song Sheet 01 §1/§2, Spec §5.2 ("the boss sings") |
| 2 | **One song sheet per song; no album cuts** ✅ (user, 28 Oct) | 28 Oct idea of two sheets per song |
| 3 | **Revenge win** = no hearts lost in the fight → gory, Mortal Kombat-style boss death; hearts to 5. **Survival win** = hearts lost, ≥½ heart left → boss and 보람 both survive; no restore ✅ | Song Sheet 01 §5 ("all 3 hearts", dodge counts as a mistake) |
| 4 | **Dodges removed for now.** A wrong answer always costs 1 heart. ❓ Dodges may return later as an optional addition | Spec §2.2, §5.2 |
| 5 | Cross-outs: the **game removes one seeded wrong option**, max one per blank, costs 1 눈치, never breaks a revenge win ✅ | — |
| 6 | Loaded blanks as Song Sheet §4. 자존심 and 엄마 일 have no fight effect ✅ | — |
| 7 | Taunts play **only on a survival win** ✅ | — |
| 8 | **Lighting effects off by default** ✅ (user: too early for lighting). The data stays in the song JSON | — |
| 9 | The music pauses **just before the blank word** (`word_start − 0.05 s`). Right answer → the word plays. Wrong or timeout → skip to the word's end + scream ✅ (W1) | Spec §5.2 |
| 10 | The spoken intro and outro are **not shown** on the 반주기 panel ✅ | — |
| 11 | "(the lights go out)" is audible in the track. Kept as is, hidden on the panel; no regeneration ✅ | Song Sheet 01 §2 (stage direction) |
| 12 | **Results appear after the last sung line; the track plays to its real end** under the results, taunts and end card. It stops only on retry, loading something else or quitting. Game over stops it at once ✅ (option b) | — |
| 13 | The fight is reachable only via `--fight eunju`. The Monday exit is wired up in Step 6, when the party comes first ✅ | — |
| 14 | **Suno Pro is the music tool** ✅ | Spec §5.7 ❓, Song Sheet §6 (Riffusion) |
| 15 | Song sheet template: paste-ready Styles (BPM first) and Lyrics blocks; **no speaker names** in the Suno lyrics (Suno read them aloud) ✅ | — |
| 16 | Track-length test widened to 125.0–126.5 s (Godot reads 125.37 s) | 4c-a prompt |
| 17 | Marker rule: a `[n]` label is zero-width when the next label starts within 0.5 s and begins with the word | 4c-a prompt ("same start") |
| 18 | `.gitignore`: `tests/shots/` fully ignored (its `.gdignore` is no longer tracked; the first capture recreates it); `data/songs/*.bak` ignored | — |
| 19 | Approved UI strings: 다시 부른다, 점수: {n}점. 피한다 (눈치 1) / 그냥 맞는다 were approved but are unused since dodges are out | — |
| 20 | Taunts use a small panel in `fight.gd`, not the Dialogue Manager box | 4b prompt |
| 21 | **Native-speaker review passed** ✅ (6 Nov): 「적어요」 (blank 6's extra option), the three loaded-blank taunts, the intro wording | Song Sheet §7 item 2 (partly) |

---

## 6. Open (defaults in brackets)

1. **Screams.** `scream1` (short), `scream2` (long), `scream3` (mid) are in `audio/sfx/`; integration is next.
   - ❓ How to pick one per wrong answer *(🟡 random, never the same twice in a row)*.
   - ❓ Record each file's provenance (tool and edits).
2. **Song Sheet 01 v0.3** has to fix:
   - the singer (보람);
   - the win rules (§5.3), with no dodges;
   - the Riffusion notes (Suno Pro);
   - the outro speaker;
   - the track and timing section (file, labels, 125.37 s);
   - the native review now done.
3. **Song sheet template, next version** ❓ The user calls it v0.3, but only v0.1 is in the Project; confirm the number.
   - Add the §4 `--mark-song` workflow.
   - `tools/song_sheet.gd` must read the new template before song 2.
   - `build_song.gd` still hard-codes the attack ids and paths; move them into the sheet.
4. **Shutdown crash** (exit 139): seen twice; not reproduced in 23 runs; HEAD is clean; cause unverified.
5. Placeholders: attacks and counters (labels), the revenge carnage card, the "END OF BUILD 4b" card, English hints, the per-attack game-over headlines (WRITE).
6. Housekeeping:
   - scrub and commit `CLAUDE.md`;
   - add Logs 005–006 to `docs/logs/`;
   - unused mp3s and stale `.import` files in `audio/songs/`;
   - Project duplicates (root vs `claude/`);
   - `LICENSE-ASSETS.md` / `README.md`, kept out of game prompts.
7. Future voice work: Fish Audio (OpenAudio S1 / S1-mini: Korean, with shout and scream markers) or the user's own voice. Kokoro and KittenTTS can't do Korean screams (no or doubtful Korean, no emotion control).
8. Everything still open in Log 005 §5 and Log 004 §7.

---

## 7. Lessons from this session

- **Claude's test specs let bugs through.** Weak timing assertions, tap-tool tests that bypassed the keyboard, and `length` set to the last label's end (116 s), which cut the track's tail.
- **The baked-JSON gap.** The game read times baked into the song JSON, so the user's Audacity edits didn't reach it. Now fixed by applying labels at load.
- **Prompts must name every input file and its exact path.** The labels file was in `docs/`, not `data/songs/`, and Claude Code correctly stopped.
- **Don't add effects ahead of the art** (the B3 lighting).

---

## 8. Repo and machines

As in Log 005 §6, plus:
- The 4c commit adds `audio/songs/dalnim_boram.mp3` and its `.import` to the public repo.
- Not in commits: `CLAUDE.md`, `art/characters/`, `docs/backups/`, `docs/songs/…labels.txt`, `docs/logs/`.

---

## 9. Next steps

1. Confirm the 4c commit was pushed.
2. **DEV:** integrate the three screams (small prompt).
3. **WRITE:** Song Sheet 01 v0.3.
4. **WRITE / DEV:** the next song sheet template version + the parser update.
5. **DEV Step 5:** 문방구 and DDEOK spending. **Step 6:** Boss 1 party pre-fight map, wiring Monday's exit to the fight. Later: Scene 00 in 3D.
6. Character design continues in its own session.
