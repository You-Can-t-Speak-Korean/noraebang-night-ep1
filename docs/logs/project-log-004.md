# Project Log 004 — Last planning before the build

*25 October 2026 · Noraebang Night · Episode 1 · Act 1: 국민학교 시대*
*Previous logs: 003 (24 Oct), 002, 001*

> **Read this first in every new session.** Read this log, then 003, 002 and 001 for anything it doesn't change, then the documents in §2.
> Markers: ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

---

## 0. Summary

- **Planning is done for now. Next session builds.** The user is tired of planning without a playable taste of the game; unresolved details get tuned **after** playing, not before.
- **Systems Spec v0.4** and **Style Brief v0.3** written: violence anywhere, hearts everywhere, exploration with traps and random spawns, the school map, pre-fight maps.
- Five answers given **after** Spec v0.4 was written (§3). **They override the spec**; no v0.5 until the game has been played.
- Build step 1 is defined (§5). The user has given permission for its Claude Code prompt.

---

## 1. Workflow rules (additions)

| # | Rule |
|---|---|
| 12 | **Build first, tune later.** Don't open new planning threads before the build. Settle only what blocks the current build step; park the rest as ❓ with a sensible default. |
| 13 | **The violence rule is gone.** Violence appears wherever it fits. (It came from the user's 20 Oct message; the user has now replaced it. The project instructions no longer state it.) |
| 14 | **Hearts are not fight-only.** That was Claude's addition in Spec v0.1, now removed. All stats are on screen in every part of the game. |
| 15 | The game is a **survival-horror RPG adventure** that teaches Korean language and history. |

---

## 2. Document map (current)

| Document | Path | Status |
|---|---|---|
| Roadmaps (Master, Episode 1, Act 1) | `docs/roadmaps/` | Frozen |
| **DDEOK Master Roadmap** | Project files: `ddeok-master-roadmap.md` (not yet in repo) | Frozen. Governs DDEOK as a token |
| Systems Spec v0.1, v0.2, v0.3 | `docs/design/` | **Superseded** |
| **Systems Spec v0.4** | `docs/design/noraebang-night-systems-spec-v0.4.md` | **Current**, with §3 overrides |
| Style Brief v0.1, v0.2 | `docs/design/` | **Superseded** |
| **Style Brief v0.3** | `docs/design/noraebang-night-style-brief-v0.3.md` | **Current** |
| Song Sheet 01 v0.2 〈달님은 계란 후라이〉 | `docs/songs/` | Current (`windup` → `countdown`) |
| Scene 01 script v0.1 | `docs/scripts/` | Current (twins' surname 손 not in the file) |
| Scene 02 script v0.1 | `docs/scripts/` | Current |
| Project Logs 001–004 | `docs/logs/` | |

Files written since Build 001 live in the Project under `claude/`. **They need adding to the repo** (§6).

---

## 3. Decisions after Spec v0.4 — these override the spec

| # | Topic | Decision | Overrides |
|---|---|---|---|
| 1 | 눈치 at the 문방구 | **Allowed but scarce:** one or two in stock. Tune after playing | Spec v0.4 §4.6 conflict → resolved as option (a), scarce |
| 2 | Anti-farming budget | **Approved:** a fixed set of items per map-day per save; reloading reshuffles placement of uncollected items only | Spec v0.4 §3.3 🟡 → ✅ |
| 3 | Heart refills | **None.** Hearts come back only from **health items** or **beating a boss** (revenge win restores to full). Health items from dialogue maybe later | Spec v0.4 §2.1 ❓ → no overnight refill ✅ |
| 4 | Death | **Outside a fight:** back to the beginning (start of Scene 01, no opening cutscene) and **everything is lost**. **Boss fights get restarts** (with hearts and 눈치 from the fight's start). A limit on restarts may come later | Spec v0.4 §3.6 ❓ → ✅ |
| 5 | Health items | **빨간약** and **반창고**, everyday items in 1979 (the user had assumed "elixirs"). Amounts: 반창고 +½, 빨간약 +1 🟡 | Spec v0.4 §2.1 ✅ |

---

## 4. Decisions from the floor-plan session (now in Spec v0.4)

| # | Decision |
|---|---|
| 1 | **Map 01 — 국민학교 (1979)** layout: 교문 · 운동장 (철봉, 모래밭, 이순신 동상) · 현관 (신발장) · 1층 복도 (교무실, 1학년 3반, 화장실, 계단) · 2층 (locked Sat, open Mon) · 골목길 (전파사, 문방구). To be tuned in play |
| 2 | **전파사** window TV carries 문태식's funeral announcement in Scene 02 |
| 3 | **문방구 opens after Scene 02**, before the 은주 fight |
| 4 | **Hidden items:** DDEOK, **secret notes** (useful info, e.g. a lyric scrap of the next song), health items; **traps** with visible gore. Reward:penalty ≈ **6:4**. Most traps −½, rare ones −1 |
| 5 | **Random placement every load** from a per-map spot pool (also in the DDEOK Master Roadmap) |
| 6 | **Optional conversations:** mostly flavor; ~1 in 5 with stakes (earn 눈치 or cost a card); no markers; once per save |
| 7 | **Examinable objects** unlock era slang codex entries |
| 8 | **Fights take place in one room.** **Pre-fight maps** only when 보람 has to walk there |
| 9 | **Boss 1 lead-up:** elevator arrival → party → cut → bathroom → walk back → 장기자랑 → 은주: "이 노래 몰라? 이 노래 모르는 애는… 죽어야 돼." → fight |
| 10 | Hearts: **max 5**, lost in halves or wholes, always on screen; damage carries into fights |

Trap list, spot pool and secret-note ideas are in Spec v0.4 §3.7 and §3.3.

---

## 5. Build plan

The order agreed for the gray-box vertical slice (each step = one Claude Code prompt, tested and committed before the next):

| Step | Contents | Status |
|---|---|---|
| **1** | **Foundation** (old steps 1 + 2 merged): Godot 4.7.2 + Forward+; 1920×1080; input map (A/D, W/S, Enter, Space); remove pixel-art settings and Galmuri; placeholder font **Noto Sans KR** (OFL); a **3D test stage** (grey room, side-on camera, one light, fog, a capsule as 보람) to prove Forward+ fog on the user's Arc B580; **GameState v0.4** (hearts in halves, 눈치 cap 7 + overflow → DDEOK, notes, leaks, `knows()`, death reset, fight-retry snapshot, versioned save); build 001's 2D opening moved to `legacy/`; headless tests (existing + new) | **Next.** User gave permission for the prompt |
| 2 | Player and maps: walking, rooms and doors, interaction, spot pools with random dealing, traps, pickups, gray-box Map 01 | |
| 3 | Dialogue in the map: W/S + Enter choices, optional conversations, Scenes 01–02 as `.dialogue` | |
| 4 | Fight player: song JSON, the reality freeze, cross-outs, dodges, loaded blanks, both wins, game over, restarts | |
| 5 | 문방구 and DDEOK spending | |
| 6 | Boss 1 pre-fight map (party) | |
| Later | Scene 00 rebuilt in 3D with the renames | |

**User's setup:** Godot 4.7.2 and Claude Code are installed on the Windows PC (Intel Arc B580) in the `noraebang-night-ep1` folder.

**DEV workflow reminders:** the Claude Code prompt is one code block; it never tells Claude Code to `git add/commit/push`. After tests pass, Claude gives the git commands with files named explicitly. Commit identity in this repo: `3th4n` + noreply (repo-level config).

---

## 6. Housekeeping before or with the first build commit

- Add to the repo: Logs 003 and 004, Spec v0.2–v0.4, Style Brief v0.2–v0.3, Scene 01 and 02 scripts, the DDEOK Master Roadmap.
- Project files contain duplicates (several docs in both the root and `claude/`). Clean-up offered; not urgent.

---

## 7. Open — tune after playing (defaults in brackets)

1. DDEOK amounts, overflow rate, 문방구 prices *(placeholders)*.
2. What skills are; whether clothes have effects *(문방구 ships with 눈치, health items and clothes)*.
3. Fight damage per wrong answer *(−1)*.
4. Final trap list and spot pool *(Spec v0.4 §3.7)*.
5. Limit on boss-fight restarts *(none)*.
6. Music tool: ACE-Step 1.5 or Suno *(placeholder track)*.
7. ComfyUI models and the art style test *(grey boxes until then)*.
8. Final Korean font *(Noto Sans KR)*.
9. Act carry-over and the shared NHMH save.
