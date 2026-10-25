# Noraebang Night — Systems Spec

*Version 0.3 · 24 October 2026 · Supersedes v0.2 (24 October 2026)*
*Applies to: the whole game. Act 1 values given where they differ.*

> **Document rules**
> - Production document. Changes are made by issuing a **new version**; earlier versions stay unchanged.
> - What is actually built, and any deviation from this spec, is recorded in the **project logs**.
> - ✅ decided · 🟡 proposed default, adjust in session · ❓ open · 🔍 verify

### What changed since v0.2
| § | Change |
|---|---|
| 1, 8 | **PC only** for now. A phone version may come later. |
| 2.2 | **눈치 cap is 7.** 눈치 earned above the cap converts into **DDEOK**. **One cross-out per blank.** |
| 2.5 | New: **DDEOK**, the shared in-game currency (off-chain for now). |
| 3, 4 | **Scenes are maps.** 보람 walks; dialogue is triggered in the map. Hidden areas hold DDEOK. |
| 4.5 | New: **movement and controls** — *Little Nightmares*-style side view, A/D + W/S, choices with W/S + Enter. |
| 4.6 | New: **the 문방구**, Act 1's shop. |
| 5.2 | **Reality freezes** at every blank, with a creeping countdown. The music pauses. |
| 5.4 | A 눈치 dodge **does not** break a revenge win. |
| 5.6 | **Loaded blanks** approved. |
| 6.1, 8 | **Live 3D** characters and rooms; **Forward+** renderer. |
| 7 | Saves designed to move **on-chain** later. |

---

## 1. Design Goals ✅

1. **Easy to understand.** A new player understands every number on screen within the first scene.
2. **Easy to maintain.** The same rules run from 1979 to 2030. New scenes, maps and songs are **data, not code**.
3. **The two halves feed each other.** Playing the social scenes well makes the fights easier.
4. **The long game matters.** What 보람 gives away follows her to the ending.
5. **PC first.** Everything is designed for keyboard and mouse on PC. A phone version is a later project.

---

## 2. Resources ✅

| Resource | Icon | Where it changes | What it does |
|---|---|---|---|
| **체력** (hearts) | ❤️ | Noraebang fights only | Survive this fight |
| **눈치** | 👀 | Earned in dialogue, bought in the 문방구, spent in fights | Makes fights easier |
| **비밀** (secret cards) | 🔒 | Lost in dialogue | Bosses use what she gives away; decides the ending |
| **DDEOK** | 🍡 | Found in hidden areas; earned from 눈치 overflow | Buys 눈치, skills and clothes |
| **점수** | 🎤 | End of each fight | Noraebang-machine score. Bragging only |

### 2.1 ❤️ 체력 — Hearts ✅
- **3 hearts per boss fight.** Reset to 3 at the start of every fight.
- Wrong answer or timeout → **−1 heart** and the attack lands in full gore.
- 0 hearts → **game over** (§5.5) → retry the fight.
- Hearts do not exist outside fights.

### 2.2 👀 눈치 — Tokens ✅
- **Earned** in dialogue scenes: a good read of the room = **+1 눈치**.
- **Bought** in the 문방구 with DDEOK — never above the cap.
- **Spent** in fights, by tapping or selecting a token during a blank:
  - **Cross out** one wrong option. **Maximum one cross-out per blank.**
  - **Dodge** one hit after a wrong answer (no heart lost; the attack plays and misses by a hair).
- **Cap: 7.** Act 1 can award exactly 7 before the first fight (1 in Scene 00, 3 in Scene 01, 3 in Scene 02).
- **Overflow:** every 눈치 earned while at the cap converts into DDEOK. ❓ Exchange rate.
- Tokens carry over between bosses within an Act. 🟡
- On game over, tokens reset to what she had **when the fight started**.

### 2.3 🔒 비밀 — Secret Cards ✅
- 보람 holds a hand of **secret cards**: private facts and her dignity.
- **Lost** when she overshares or compromises herself in dialogue. **Cards never come back.** Losing a card already lost costs nothing more.
- A lost card becomes **known** by whoever is in the room (the scene's boss, or a named person).
- **Leak rule:** some people pass on what they hear. Act 1: **함현정 → 현정 엄마** (Boss 3).
- What a known card does:
  - **Dialogue:** the knower gets extra **taunts** (§4.4).
  - **Fights:** the boss gets **loaded blanks** (§5.6).
- Cards still held decide the **ending** (whole game). 🟡 They may also vary each Act's ending.

**Act 1 hand**
| Card id | Card | What it guards |
|---|---|---|
| `dad_country` | 아빠 나라 | Her father's country |
| `dad_story` | 아빠 이야기 | Her father's war service and why he can't go home |
| `our_home` | 우리 집 | Her home, food and family life |
| `mom_job` | 엄마 일 | Her mother's job |
| `mom_salary` | 엄마 월급 | How much her mother earns |
| `dad_drinking` | 아빠 주량 | How much her father drinks |
| `pride` | 자존심 | Her dignity: lost by laughing along, accepting humiliation, bowing to a peer, or apologizing for existing |

아빠 나라 is **one card among many**; the satire targets Korean nosiness in general.
❓ Later Acts add new cards. Whether Act 1 cards carry into Act 2 depends on saving (§7).

### 2.4 🎤 점수 — Noraebang Score ✅
- Shown at the end of every fight, styled after a real noraebang machine.
- **점수 = 100 × correct answers ÷ total blanks**, rounded.
- 100점 gets the fanfare. 🟡 Low scores get era-appropriate insults from the machine.

### 2.5 🍡 DDEOK — Shared currency ✅
- **DDEOK** is the in-game currency shared by **all NHMH games** (Noraebang Night, Hangul Hiking Trip, and a third game, Bunshik Hell). It carries across Acts and games.
- **Off-chain for now.** It is planned to move on-chain (Sui) later, together with saves (§7). Nothing in this spec depends on the chain.
- **Earned by:**
  - finding it in **hidden areas** of maps (§3.2);
  - **눈치 overflow** (§2.2).
- **Spent at:** the era's shop — in Act 1, the **문방구** (§4.6) — on **눈치**, **skills** and **clothes**.
- ❓ Amounts per hidden find, exchange rates and prices.
- ❓ How DDEOK relates to Hangul Hiking Trip's own points and markets. To be settled in an **NHMH-wide DDEOK spec**, not here.

---

## 3. Game Loop and Maps

### 3.1 Loop ✅
```
Act
 └─ Boss loop (×4 in Act 1)
     ├─ Map: dialogue scene 1      → explore · earn 👀 · lose 🔒 · find 🍡
     ├─ Map: dialogue scene 2      → explore · earn 👀 · lose 🔒 · find 🍡
     ├─ (문방구, when available)   → spend 🍡
     ├─ Noraebang fight            → spend 👀 · lose ❤️ · 🎤 score
     └─ Aftermath beat             → outcome, taunts, year change
```

### 3.2 Maps ✅
- Every dialogue scene takes place in a **map**: a place 보람 walks through (e.g. Scene 01–02: the 1학년 classroom, hallway, school gate).
- Maps are **side-on**, built from connected rooms (§4.5).
- Dialogue starts when 보람 approaches a character, or automatically when the script says so. ❓ Which lines are forced and which are optional.
- **Hidden areas** in each map hold DDEOK. 🟡 Examples: behind the 조개탄 stove, under the teacher's desk, a gap in the school fence.
- Each map needs a **floor plan** before it's built. ❓ Floor plans for Scenes 00–02.
- **Fights are not maps.** The arena is a fixed stage; 보람 does not walk during a fight.

---

## 4. Dialogue Scenes

### 4.1 Flow ✅
1. Lines play with live 3D characters in the map; advance with **Enter**, **Space** or a click.
2. At a choice, **2–4 options** appear. Select with **W/S + Enter**, or click.
3. The choice resolves its one effect (§9.1) with a clear on-screen cue:
   - +1 눈치 → eye icon flies to the token bar (or converts to 🍡 when full).
   - −1 비밀 → the card cracks and flips to the knower's side of the screen.
4. Movement is locked while dialogue is on screen.

### 4.2 Choice types ✅
| Type | Effect | Example (Scene 01) |
|---|---|---|
| **Good read** | +1 👀 | "우리 반에 은주는 세 명이나 있잖아." |
| **Overshare** | −1 🔒 (fact card) | "우리 아빠는 소주 세 병 마셔!" → 아빠 주량 |
| **Compromise** | −1 🔒 자존심 | "서울에서 왔어요." (존댓말 to a classmate) |
| **Neutral** | none | "너는?" |

### 4.3 Timing
- ✅ **Act 1:** no timers on dialogue choices.
- 🟡 Later Acts: timed choices in high-pressure moments; timeout counts as the worst option.

### 4.4 Conditional lines ✅
- Lines may play only when a card is **lost** (Scene 01: 은주 mocks the apology to the 반장).
- **Taunts** play only when the speaker **knows** a card (Scene 02: taunts for 아빠 나라, 아빠 주량, 엄마 월급, 자존심).
- Conditional lines never offer choices and never change state.

### 4.5 Movement and controls ✅
- **Camera:** side-on, *Little Nightmares*-style dollhouse view. The camera follows 보람 with fixed framing per room.
- **Movement:**

| Key | Action |
|---|---|
| **A / D** | Walk left / right |
| **W / S** | Doors, stairs, moving between rooms or depth layers; up/down in menus |
| **Enter** (or Space) | Talk, interact, confirm |
| **Mouse** | Click choices, buttons, 눈치 tokens |

- 🟡 Interaction prompt appears near objects and characters 보람 can use or talk to.
- 🟡 Controller support later. Phone version later, with an on-screen joystick.

### 4.6 The 문방구 (Act 1 shop) ✅
- Act 1's shop is the **문방구**. Each Act has a shop that fits its era. 🟡 (e.g. a 매점, a 편의점…)
- **Sells:** 👀 눈치 (never above the cap), **skills**, **clothes**.
- ❓ What skills are. To be defined in a design session.
- ❓ Clothes: cosmetic only, or with effects?
- ❓ When the 문방구 opens in Act 1 (e.g. between Scene 02 and the 은주 fight).

---

## 5. Noraebang Fights

### 5.1 Structure ✅
- One original song per boss, in **four phases**:

| Phase | Section | Blanks 🟡 | Blank difficulty | Attack intensity |
|---|---|---|---|---|
| 1 | Verse | 3 | Easiest | Nasty |
| 2 | Chorus | 3 | Easy | Worse |
| 3 | Bridge | 2 | Moderate | Rule-breaking |
| 4 | Final chorus | 2 | Hardest | Signature carnage |

🟡 **10 blanks per song** in Act 1.

### 5.2 A single blank: the freeze ✅
1. The song plays as a live musical: the boss sings, the room moves, attacks wind up.
2. At each blank, **reality freezes.** The music stops. Everything holds still — except the attack, which **creeps toward 보람**. That creep is the countdown.
3. The lyric line shows on the arena's 반주기 screen with one blank and its options. Act 1: **3 options** 🟡.
4. The player selects an option (W/S + Enter, or click). They may spend 👀 first (one cross-out per blank, or a dodge).
5. **Right:** time unfreezes; the counter plays; the song continues.
6. **Wrong, or the attack reaches her:** time unfreezes; −1 ❤️ and the attack lands in gore — unless the player spends 👀 to dodge.
- 🟡 Act 1 countdown: **5 seconds**; later Acts shorten it.
- Because the music pauses, tracks don't need written-in gaps.

### 5.3 Counters ✅
- Every attack has its own authored counter, either **slapstick** or **gory**.
- 🟡 Verse and chorus lean slapstick; bridge and final chorus lean gory. Every boss's last counter is the biggest payoff.

### 5.4 Winning ✅
| Win | Condition | Outcome |
|---|---|---|
| 🏆 **Revenge win** | No wrong answers and all 3 hearts | The boss dies a **brutal carnage death caused by their own sloppy mistake** |
| 😐 **Survival win** | At least 1 heart left, with mistakes | The boss is **quelled** and stops bullying 보람 |

- Cross-outs and dodges **do not** break a revenge win. *(A dodge only follows a wrong answer, so in practice a revenge win means no wrong answers.)* ❓ Confirm: does a wrong answer saved by a dodge still count as a mistake?
- Both wins → 🎤 점수 screen → aftermath beat.

### 5.5 Game over ✅
- The news anchor **문태식** reports 장보람's gruesome death in the same flat tone as the opening assassination. Classmates ignore it.
- 🟡 The headline names the attack that landed the final hit.
- Retry restarts the fight from Phase 1 with 3 hearts and pre-fight 👀.

### 5.6 Known cards in fights ✅
- **Songs never change their lyrics** because of lost cards.
- **Loaded blank:** for each card the boss knows, one predefined blank gets **4 options instead of 3**, and its attack lands with a nastier flourish.
- **Aftermath taunts:** the boss's knowledge shows in the aftermath beat.

### 5.7 Songs ✅
- **Songs are songs.** Bosses never sing about their real lives.
- Strange, playful art pieces. Loose resonance with the boss is fine if well done; pure randomness is fine if the song is good.
- **Topic categories:** Food Love Songs · Animal Confessions · Weather Romance · Object Laments · Body Parts · Space & Fantasy · Numbers & Counting · Fake Jingles.
- The **boss** picks the song. 🟡 In certain later Acts the **player** picks from the 반주기 songbook.
- **Original songs only.** Genre parodies, title or hook riffs and public-domain melodies are fine.
- ❓ Music tool: ACE-Step 1.5 or Suno (paid).
- Each song is delivered as a **vocal** and an **instrumental** track, with timestamps for every blank line.

---

## 6. Godot Pipeline

### 6.1 Engine, renderer, addons
- ✅ **Godot 4.7.2.** Build 001 was made with 4.7.1. 🔍 Confirm it opens unchanged.
- ✅ **Forward+ renderer** (PC). Needed for the fog and lighting in Style Brief v0.2. Build 001 uses Compatibility and must be switched. 🔍 Confirm which fog and lighting features require Forward+.
- ✅ **Live 3D** characters and rooms, side-on camera (Style Brief v0.2).
- ✅ **Dialogue Manager 4.1.0** (MIT).
- ✅ All licences compatible with AGPL-3.0 code.

### 6.2 Principle ✅
> **Scenes, maps and songs are data. Code runs any of them.**
> Adding a boss = `.dialogue` files, a map scene built from shared parts, a song file, art and audio. No new systems code.
> Stage directions in `.dialogue` files call methods on the map or scene that plays them.

### 6.3 Dialogue files ✅
Dialogue Manager format, unchanged from v0.2:

```
~ start

$> GameState.set_boss("eunju")
은주: 너 어디서 왔어?
- 서울에서 왔어.
	$> GameState.add_nunchi(1)
	은주: 흥. 서울 사람 같지 않은데.
- 우리 아빠는 에티오피아 사람이야.
	$> GameState.lose_secret("dad_country")
	은주: 에티오피아? 그게 어디야?
- 너는?
	은주: 나? 우리 집은 아파트야. 엘리베이터도 있어.

$> GameState.lose_secret("our_home", "hyunjeong")   # leak rule applies

if not GameState.has_secret("pride")
	은주: 아까 반장한테 "미안해…" 했지?
if GameState.knows("eunju", "dad_drinking")
	은주: 너희 아빠는 오지 마. 소주 세 병 마시잖아.
=> END
```

### 6.4 Song files ✅
Unchanged from v0.2 (JSON in `data/songs/`, with `phases`, `loaded`, `outcomes`). `windup` is renamed **`countdown`** (seconds of frozen time).

### 6.5 Attacks and counters ✅
Named animation sets (`booger_flick`, `…_slapstick`, `…_gory`), referenced by name from song files. In live 3D these are animations and effects on the boss, 보람 and props.

### 6.6 Music sync ✅
- Blank times come from the track's lyric timestamps. At each blank the track **pauses**; it resumes after the answer.
- Playback position is corrected for audio output latency (Godot's "Sync the gameplay with audio and music" guide).

### 6.7 Global state (`GameState` autoload)
| Variable / method | Type | Notes |
|---|---|---|
| `hearts` | int | 0–3, fights only |
| `nunchi` | int | 0–7 |
| `ddeok` | int | 🆕 Shared currency balance |
| `secrets_held` | array of card ids | Starts with the Act's hand |
| `secrets_known_by` | dict: card → person ids | After leaks |
| `leaks` | dict: person → person ids | From `data/secrets/act1_leaks.json` |
| `found_ddeok` | array of ids | 🆕 Hidden spots already collected (each pays once) |
| `owned_items` | array of ids | 🆕 Skills and clothes bought |
| `scores` | dict: boss → 점수 | Best score per boss |
| `outcomes` | dict: boss → "revenge" / "survival" | |
| `progress` | string | Current map / scene / boss |
| `codex` | array | Era slang unlocked |
| `add_nunchi(n)` | method | Applies the cap; overflow → `ddeok` |
| `lose_secret(card, by = "")` | method | Applies leaks |
| `has_secret(card)`, `knows(person, card)`, `cards_known_by(person)` | methods | |

### 6.8 Project folders ✅
```
res://
  addons/dialogue_manager/
  data/dialogue/   data/songs/   data/secrets/   data/shop/   # shop: 문방구 stock and prices
  maps/            # 🆕 map scenes (rooms, hidden areas, triggers)
  characters/      # 🆕 3D characters and animations
  audio/songs/  audio/sfx/
  art/             # textures, UI, fonts
  scenes/          # fight arena, dialogue box, HUD, menus
  scripts/         # GameState, loaders, player controller, fight logic
  tests/
  docs/            # ignored by Godot
```

---

## 7. Saving ✅
- Autosave at the start of every map, dialogue scene and fight. Save holds the full `GameState`.
- **Designed to move on-chain later:** the save is **compact**, **versioned** (`save_version` field) and separate from the game's code and assets, so moving it on-chain later doesn't mean redesigning it. Off-chain for now.
- DDEOK and the save sit together, since both go on-chain.
- ❓ Act carry-over format (standalone releases); shared save across NHMH games (NHMH-wide DDEOK spec).

---

## 8. UI, Input and Display ✅
- **Platform:** PC (Windows first 🟡; Linux).
- **Input:** keyboard (A/D, W/S, Enter, Space) and mouse. 🟡 Controller later.
- **Display:** live 3D at 1920×1080, Forward+. The 640×360 pixel-art viewport and the Galmuri pixel font are dropped. ❓ New Korean font.
- **HUD in maps and dialogue:** 👀 tokens, 🍡 DDEOK, 🔒 cards (cards a person knows shown on their side).
- **HUD in fights:** ❤️ hearts, 👀 tokens, lyric line and options on the 반주기 screen, boss.
- 🟡 Text: Korean primary; optional English subtitles via Godot's translation system.

---

## 9. Writer's Rules ✅

### 9.1 Scenes
1. **Every dialogue choice does exactly one thing:** `+1 눈치`, `−1 비밀 card`, or nothing.
2. Each choice point should offer one good-read (눈치) answer.
3. **No placeholder names.** Every speaking character has a real name.
4. **No real names.** Satirical fictional names only.
5. No violence outside noraebang fights; no sexual content, ever.
6. Facts the user has confirmed or deliberately bent are noted in the script file, not re-checked.

### 9.2 Songs
1. **Every blank does exactly one thing:** right = counter, wrong = −1 heart.
2. Distractors must be plausible and teach something.
3. Blanks get harder phase by phase.
4. Lyrics never reference a boss's real life or 보람's secrets.

### 9.3 Maps
1. Every map has at least one hidden DDEOK spot. 🟡
2. Hidden spots fit the place and the era.

---

## 10. Open Questions
1. DDEOK amounts, exchange rate for overflow, 문방구 prices (§2.5, §4.6).
2. What skills are; whether clothes have effects (§4.6).
3. When the 문방구 opens in Act 1 (§4.6).
4. Floor plans for Scenes 00–02; which dialogue is forced vs optional (§3.2).
5. Does a wrong answer saved by a dodge still count as a mistake for the revenge win? (§5.4)
6. Music tool: ACE-Step 1.5 or Suno (§5.7).
7. Act carry-over and the NHMH-wide shared save and DDEOK spec (§2.5, §7).
8. New Korean font (§8).
