# Project Log 003 — Housekeeping, Act 1 scripts, Spec v0.3, live 3D

*24 October 2026 · Covers sessions 23–24 October 2026*
*Noraebang Night · Episode 1 · Act 1: 국민학교 시대*
*Previous logs: 001 (build), 002 (art direction)*

> **Read this first in every new session.** Read this log, then 002 and 001 for anything it doesn't change, then the documents in §2.
> Markers: ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

---

## 0. Summary

- The repo moved to the GitHub organization; history rewritten so every commit uses the `3th4n` noreply identity.
- **Project instructions with four modes (DEV, CHAT, WRITE, STRATEGY)** now govern all sessions.
- **Scene 01 and Scene 02 scripts approved.** The 김은주 boss loop has both dialogue scenes.
- **Systems Spec v0.3** and **Style Brief v0.2** written. Big changes: **live 3D**, **maps with WASD movement**, **DDEOK** currency, **문방구**, **the reality freeze** in fights, **눈치 cap 7**.
- Build 001's presentation (640×360 pixel art, code-drawn puppets, Compatibility renderer) is now **obsolete**. Its logic (GameState, dialogue flow, tests) is reusable.

---

## 1. Workflow rules (additions to Logs 001–002)

| # | Rule |
|---|---|
| 7 | **Project instructions and modes govern.** DEV builds through **Claude Code prompts** written by Claude and run by the user; Claude never tells Claude Code to `git add/commit/push`. The user commits with commands Claude provides. |
| 8 | **Repo access:** Claude may **clone and view** the repo. Claude **never edits** it without explicit permission. |
| 9 | **No placeholder names.** Every speaking character gets a real name. |
| 10 | **Don't ask the user to check facts.** Verify where possible; accept the user's confirmations and **deliberate bends** of history, and note them in the script file. |
| 11 | **Approved scripts are filed straight away** (no second permission round). |

---

## 2. Document map

| Document | Path | Status |
|---|---|---|
| Master / Episode 1 / Act 1 roadmaps | `docs/roadmaps/` | Frozen records |
| Systems Spec v0.1 | `docs/design/noraebang-night-systems-spec-v0.1.md` | **Superseded** |
| Systems Spec v0.2 | `docs/design/noraebang-night-systems-spec-v0.2.md` | **Superseded** (same day) |
| **Systems Spec v0.3** | `docs/design/noraebang-night-systems-spec-v0.3.md` | **Current** |
| Style Brief v0.1 | `docs/design/noraebang-night-style-brief-v0.1.md` | **Superseded** |
| **Style Brief v0.2** | `docs/design/noraebang-night-style-brief-v0.2.md` | **Current** |
| Song Sheet 01 v0.1 〈생일 축하해, 나만〉 | — | Superseded (not in repo) |
| **Song Sheet 01 v0.2** 〈달님은 계란 후라이〉 | `docs/songs/songsheet-01-eunju-dalnim-v0.2.md` | Current. Note: its `windup` field is now `countdown` (Spec v0.3 §6.4); its §4 loaded-blank table matches the approved rule |
| **Scene 01 script v0.1** | `docs/scripts/scene-01-eunju-scene-1-v0.1.md` | Current (twins' surname 손 not yet in the file) |
| **Scene 02 script v0.1** | `docs/scripts/scene-02-eunju-scene-2-v0.1.md` | Current |
| Project Logs 001–003 | `docs/logs/` | |

Spec v0.2, v0.3, Style Brief v0.2, both scripts and this log are in the Project files under `claude/`. **Not yet in the repo** — the user adds them when ready.

---

## 3. Repo and identity

| Item | Value |
|---|---|
| Repo | `github.com/You-Can-t-Speak-Korean/noraebang-night-ep1` (public). Org display name: 니가 한국어 못해 |
| Commit identity (this repo only) | `3th4n <273777105+eth4nh4rdy@users.noreply.github.com>`, set with repo-level `git config` |
| History | Rewritten 23 Oct and force-pushed: all three commits now show only `3th4n` + noreply. Old emails may still be cached by GitHub or anyone who cloned before. |
| Current commits | `7a1ca8c` Initial commit · `f346305` roadmaps · `0e1ea9c` Build 001 |
| Repo contents | Build 001, Logs 001–002, Style Brief v0.1, Spec v0.1, roadmaps, Song Sheet v0.2 |

---

## 4. Story and writing decisions

| # | Decision | Status |
|---|---|---|
| 1 | Names: **박철수, 오동진** (boys, on the 떠든 사람 list), **최은주, 한은주** (the other two 은주s), **윤상훈** (반장), **오경자** (1학년 담임), **문태식** (TV news anchor) | ✅ |
| 2 | 은주's friends: **손미숙 and 손미경, twin sisters** | ✅ |
| 3 | **함현정** debuts in Scene 02 | ✅ |
| 4 | **현정 엄마 is 육성회 회장** (Boss 3) | ✅ |
| 5 | **Leak rule:** cards told to 현정 become known to 현정 엄마 | ✅ |
| 6 | **은주's party: Saturday 3 Nov 1979, the day of the state funeral** (date confirmed by the user) | ✅ |
| 7 | **Home 반주기 in 1979 is a deliberate anachronism** (they appeared in 1986) | ✅ |
| 8 | The mother's job stays hidden on 은주's form (job still undecided) | ✅ |
| 9 | 2C in Scene 02 (wrong vocative "은주아") costs 자존심 and lands the title joke "너 한국말 못해?" | ✅ |

**Pending changes to Scene 00** (when its final version is built):
- Speakers renamed: 남자애 1 → 박철수, 남자애 2 → 오동진, 반장 → 윤상훈, 선생님 → 오경자, TV 앵커 → 문태식.
- **정미경** on the blackboard renamed (clashes with 손미경). 최민수 stays.
- Rebuilt in live 3D as a map.

---

## 5. Systems and art decisions (now in Spec v0.3 / Style Brief v0.2)

| # | Decision | Status |
|---|---|---|
| 1 | **PC only** for now; phone version maybe later (on-screen joystick) | ✅ |
| 2 | **Live 3D** characters and rooms, side-on *Little Nightmares*-style camera; **Forward+** renderer | ✅ |
| 3 | **Godot 4.7.2** (confirmed latest stable 24 Oct; build 001 used 4.7.1). Dialogue Manager 4.1.0 still current | ✅ |
| 4 | **Maps:** dialogue scenes happen in explorable places with hidden areas | ✅ |
| 5 | **Controls:** A/D walk; W/S doors, stairs, rooms, menus; Enter to talk/confirm; choices with **W/S + Enter** or mouse. Controller later | ✅ |
| 6 | **Reality freeze:** at every blank the music stops and the world freezes; the attack creeps toward 보람 as the countdown | ✅ |
| 7 | **Loaded blanks** approved; a 눈치 **dodge doesn't break a revenge win** | ✅ |
| 8 | **눈치 cap 7**; overflow converts to DDEOK; **one cross-out per blank**; 문방구 can't sell 눈치 above the cap | ✅ |
| 9 | **DDEOK:** shared in-game currency across all NHMH games (Noraebang Night, Hangul Hiking Trip, **Bunshik Hell**). **Off-chain for now**; Sui later. Found in hidden areas; earned from 눈치 overflow | ✅ |
| 10 | DDEOK buys **눈치, skills and clothes** at the era's shop: **문방구** in Act 1 | ✅ |
| 11 | Saves designed to go **on-chain later**: compact, versioned | ✅ |
| 12 | User says legal clearance for DDEOK is handled; risks were flagged (Korean Game Industry Act / GRAC, Steam's blockchain ban, server-side minting, key handling) | ✅ noted |
| 13 | Bunshik Hell: a third NHMH game. **Parked**; no details yet | ✅ |

---

## 6. Build 001 status vs the new spec

| Part of build 001 | Status |
|---|---|
| `scripts/game_state.gd` | Reusable; needs v0.3 changes (cap 7 + overflow, DDEOK, leaks, `knows()`, outcomes, save version) |
| `data/dialogue/scene_00_opening.dialogue` | Reusable format; content needs the Scene 00 renames |
| `scenes/ui/dialogue_box.gd` | Logic reusable; needs W/S + Enter choice selection and a new look |
| `scenes/ui/hud.gd` | Replace (new HUD with DDEOK) |
| `scenes/opening/*` (code-drawn puppets, 2D) | **Obsolete** (live 3D) |
| `project.godot` | Change: Forward+, 3D, 1920×1080, input map, drop pixel-art settings and Galmuri font |
| `tests/test_runner.gd` | Reusable pattern |

---

## 7. Open questions

1. DDEOK amounts, overflow exchange rate, 문방구 prices.
2. What **skills** are; whether clothes have effects.
3. When the 문방구 opens in Act 1.
4. **Floor plans** for the Act 1 school maps; which dialogue is forced vs optional; where DDEOK hides.
5. Does a wrong answer saved by a dodge still count as a mistake for the revenge win? (Spec v0.3 §5.4)
6. Music tool: ACE-Step 1.5 or Suno.
7. ComfyUI models for the style test (not settled in the Hangul Hiking Trip session either).
8. New Korean font.
9. NHMH-wide DDEOK and shared-save spec (with Hangul Hiking Trip, whose Log B also names its points DDEOK).
10. Project files clean-up: duplicate copies of several documents.

---

## 8. Next steps

1. **Floor plan session** (CHAT/WRITE): the Act 1 school map for Scenes 00–02.
2. **DEV step 1: build plan** for the gray-box vertical slice (see the order in the session reply of 24 Oct).
3. **In parallel:** ComfyUI model choice → art style test.
