# Project Log 001 — Build starts: Scene 00 (Opening)

*22 October 2026 · Noraebang Night · Episode 1 · Act 1: 국민학교 시대*

> **Read this first in every new session.** Project logs carry context between sessions. Read the latest log, then the documents it points to.

---

## 0. Workflow rules (permanent)

1. **Roadmaps are never modified.** They are records of the original plan. Detail flows down: Master → Episode → Act roadmaps.
2. **Project logs record what was actually built** and every deviation from the roadmaps and specs. One log per build session, numbered.
3. **Production docs (specs, song sheets) are versioned.** A change is a new file (v0.2, v0.3…); old versions are kept unchanged.
4. **Lyrics and scripts are proposed in code boxes first.** They become files only after approval.
5. **No sexual content, ever.** Violence only in noraebang fights. No real names; satirical fictional names only.

---

## 1. Document map

| Document | Path | Status |
|---|---|---|
| Master Roadmap | `docs/roadmaps/noraebang-night-master-roadmap.md` | Frozen record |
| Episode 1 Roadmap | `docs/roadmaps/noraebang-night-ep1-school-days-roadmap.md` | Frozen record |
| Act 1 Roadmap | `docs/roadmaps/noraebang-night-act1-gungminhakgyo-roadmap.md` | Frozen record |
| Systems Spec v0.1 | `docs/design/noraebang-night-systems-spec-v0.1.md` | Current; v0.2 pending (§4) |
| Song Sheet 01 v0.1 〈생일 축하해, 나만〉 | `docs/songs/songsheet-01-eunju-birthday-v0.1.md` | **Superseded** by v0.2 |
| Song Sheet 01 v0.2 〈달님은 계란 후라이〉 | `docs/songs/songsheet-01-eunju-dalnim-v0.2.md` | Current |
| Hangul Hiking Trip Master Roadmap | Project files (not in this repo) | Separate game |

---

## 2. What was built this session

| Item | Path | Notes |
|---|---|---|
| Godot project | `project.godot` | Godot **4.7.1** (latest stable at build start). 640×360 pixel viewport, scaled ×2 to 1280×720. Compatibility renderer (for web and mobile). |
| Dialogue Manager | `addons/dialogue_manager/` | **v4.1.0** (MIT), unmodified. Requires Godot 4.6+. |
| Korean pixel font | `art/fonts/Galmuri11.ttf`, `Galmuri11-Bold.ttf` | Galmuri (OFL 1.1). Placeholder until the art style test decides the final font. |
| GameState autoload | `scripts/game_state.gd` | 체력 (3), 눈치 (cap 5), 비밀 cards, who knows which card, scores, retry rules. Implements spec §2 and §6.7. |
| Act 1 secret cards | `data/secrets/act1_cards.json` | 7 cards (see §3). |
| Scene 00 script | `data/dialogue/scene_00_opening.dialogue` | The approved opening script, as data. |
| Opening scene | `scenes/opening/opening.tscn` + `opening.gd` | Dinner → BANG → blood-smear title → classroom → first choice → hand-off to 은주. All art drawn in code (placeholders). |
| Dialogue box | `scenes/ui/dialogue_box.gd` | Reusable. Tap to finish typing, tap to advance, big choice buttons. Supports `[speed=]` and `[next=]`. |
| HUD | `scenes/ui/hud.gd` | 눈치 pips (top right), secret cards (top left). Lost cards shake and turn red; floating "+1 눈치" / "−1 비밀" text. |
| Placeholder characters | `scenes/opening/puppet.gd` | Blocky code-drawn figures. Replace with sprites later. |
| Tests | `tests/test_runner.gd` | Headless. Plays all three branches of the first choice; checks the writer's rule. **25 checks, 0 failed.** |
| Screenshot tool | `tests/capture.tscn` | Auto-plays the opening and saves PNGs (needs a display). |
| Licences | `LICENSE` (AGPL-3.0-or-later), `LICENSE-ASSETS.md` | Code open; story, songs, art, characters all rights reserved. |

### How a scene works
The `.dialogue` file drives everything. Stage directions are mutations such as `$> stage("classroom")`, `$> bang()`, `$> board_add("장보람")`. They call methods on the scene that plays the file (`opening.gd`), which animate and then return. **A new scene = a new `.dialogue` file + a scene script with its stage directions.**

### Scene 00 as built
- First choice (반장: "장보람. 떠들었어. 이름 적었어."):
  - A "미안해…" → −1 비밀 **자존심** (now known by `banjang`)
  - B "나 아무 말도 안 했는데?" → nothing; he adds two check marks
  - C "어? 선생님 오신다!" → +1 눈치; he wipes the board and flees; "아무도 고맙다고 하지 않았다."
- The one tutorial line: "답을 누르세요. 어떤 답은 나중에 도움이 돼요." It disappears after the first choice.
- Ends on an end card ("다음: SCENE 01 — 김은주") with a restart button, until Scene 01 exists.

---

## 3. Decisions made since the frozen documents

These are decided but **not yet in a spec**. They go into Systems Spec v0.2.

| # | Decision | Source |
|---|---|---|
| 1 | Secret cards include absurdly intrusive ones. Act 1 draft hand: 아빠 나라, 아빠 이야기, 우리 집, 엄마 일, **엄마 월급**, **아빠 주량**, 자존심 | Session 21 Oct |
| 2 | **Two win types.** Revenge win: no mistakes, all 3 hearts → the boss dies a brutal death from their own sloppy mistake. Survival win: mistakes made → the boss is quelled and stops bullying 보람. A 눈치 dodge counts as a mistake; a 눈치 cross-out does not | Session 21 Oct |
| 3 | **Songs are songs.** Bosses don't sing about their real lives. Privacy and 눈치 live in dialogue scenes, not lyrics | Session 21 Oct |
| 4 | Songs are strange, playful art pieces drawn from **topic categories** (Food Love Songs, Animal Confessions, Weather Romance, Object Laments, Body Parts, Space & Fantasy, Numbers & Counting, Fake Jingles). Loose resonance with the boss is fine if well done; pure randomness is fine if the song is good | Session 21 Oct |
| 5 | Boss picks the song. Player picks from the songbook only in certain later Acts | Session 21 Oct |
| 6 | Lost cards don't add lyrics. Proposed: each card a boss knows makes one blank "loaded" (4 options instead of 3) and adds a taunt in the aftermath. **Not yet approved** | Song Sheet v0.2 §4 |
| 7 | **Ethiopia is not a central theme.** 아빠 나라 is one card among many; the satire targets Korean nosiness in general. The Act 1 roadmap's Ethiopia-heavy spine (홍대중 / Derg) should be softened when his scenes are written | Session 21 Oct |
| 8 | Songs are **original**. No parodies of copyrighted melodies. Genre parodies, title/hook riffs and public-domain melodies are fine | Session 21 Oct |
| 9 | Music generation: **ACE-Step 1.5** (MIT, runs locally, Korean lyrics, stem separation, auto lyric timestamps) or **Suno paid**. Not decided. Check ACE-Step model-weight licence on Hugging Face before release | Session 22 Oct |
| 10 | Input: mouse click or touch tap only | Session 21 Oct |
| 11 | Counters can be gory or slapstick | Session 21 Oct |

---

## 4. Known gaps and deviations

- **All art is placeholder**, drawn in code. Characters are blocks. The art style test hasn't happened.
- **No audio yet.** 〈그 새우, 그 짜장〉 is a text fragment only; the full song needs its own lyric proposal.
- The 1학년 담임 is unnamed ("선생님"); 정정훈 arrives in 2학년.
- Card icons (emoji) are in the data but not shown; the pixel font has no emoji.
- Saving (spec §7) is not built. `GameState.to_dict()` exists for it.
- 🔍 Unverified for Scene 00: 1979 1학년 class sizes (60–70+), regular broadcasts and cartoons replaced by mourning coverage on 27 Oct 1979, Saturday classes.

---

## 5. Next steps

1. **Scene 01: 김은주 Scene 1** — "너 어디서 왔어?" Script proposal in a code box, then build.
2. **Scene 02: 김은주 Scene 2** — the invitation trap.
3. **Systems Spec v0.2** — fold in §3.
4. **The fight player** — reads a song JSON and runs blanks, attacks, counters, hearts, 눈치 spending, both win types and the news-anchor game over. Build it with a placeholder track first.
5. **〈달님은 계란 후라이〉 track** — generate with ACE-Step or Suno; get timestamps for the song JSON.
6. **Art style test** — one 1979 classroom and one sprite of 보람.
7. Native-speaker review of all Korean so far.

---

## 6. Repo and environment notes

- Repo: `github.com/eth4nh4rdy/noraebang-night-ep1`. On 21 Oct a push failed because the local machine was signed in to GitHub as `sm33f3r`, not the owner. Fix: sign in as the owner (`gh auth login`) or add `sm33f3r` as a collaborator.
- Git doesn't track empty folders; `.gitkeep` files keep the empty asset folders.
- `.godot/` is ignored. Commit the `*.uid` files Godot generates.
