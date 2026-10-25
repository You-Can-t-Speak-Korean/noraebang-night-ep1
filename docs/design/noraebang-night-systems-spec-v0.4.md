# Noraebang Night — Systems Spec

*Version 0.4 · 25 October 2026 · Supersedes v0.3 (24 October 2026)*
*Applies to: the whole game. Act 1 values given where they differ.*

> **Document rules**
> - Production document. Changes are made by issuing a **new version**; earlier versions stay unchanged.
> - What is actually built, and any deviation from this spec, is recorded in the **project logs**.
> - **DDEOK as a token** (supply, emission, NFTs, stores, staking, on-chain) is governed by the **DDEOK Master Roadmap**. This spec covers only how DDEOK works inside Noraebang Night.
> - ✅ decided · 🟡 proposed default, adjust in session · ❓ open · 🔍 verify

### What changed since v0.3
| § | Change |
|---|---|
| 1, 9 | **Violence throughout the game**, where it fits. The "violence only in fights" rule is removed. |
| 2.1 | **Hearts exist everywhere** and are always on screen. **Maximum 5** (10 halves). Lost in **halves or wholes**. **No automatic refill.** |
| 2.1, 5.4 | **Revenge wins restore hearts to full.** |
| 2.5 | DDEOK aligned with the DDEOK Master Roadmap (off-chain mode now; modes never mix; fair-play rule). |
| 3.3 | New: **exploration** — hidden DDEOK, secret notes, health items and traps; reward:penalty ≈ 6:4; **random placement every load**. |
| 3.4 | New: **optional conversations** — mostly flavor, rare stakes, no markers. |
| 3.5 | New: **pre-fight maps**, only when 보람 has to walk to the fight. |
| 3.6 | New: **death outside a fight** restarts Scene 01 (no opening cutscene). |
| 3.7 | New: **Map 01 — 국민학교 (1979)**. |
| 4.6 | 문방구 also sells 빨간약 and 반창고. 눈치 sales flagged against the DDEOK fair-play rule. |
| 5.1–5.5 | Fights use the global hearts (no reset to 3). |

---

## 1. Design Goals ✅

1. **Easy to understand.** Every number on screen is clear within the first scene.
2. **Easy to maintain.** The same rules run from 1979 to 2030. New scenes, maps and songs are **data, not code**.
3. **The two halves feed each other.** Playing the social scenes well makes the fights easier.
4. **The long game matters.** What 보람 gives away follows her to the ending.
5. **Survival horror.** Risk everywhere, scarce healing, violence wherever it fits. Exploring makes players nervous and eager at the same time.
6. **PC first.** Keyboard and mouse. A phone version is a later project.

---

## 2. Resources ✅

All resources are **on screen in every part of the game**.

| Resource | Icon | Changes | What it does |
|---|---|---|---|
| **체력** (hearts) | ❤️ | Lost to traps, fights and other dangers; restored by health items and revenge wins | Survival. 0 = death |
| **눈치** | 👀 | Earned in dialogue; spent in fights | Makes fights easier |
| **비밀** (secret cards) | 🔒 | Lost in dialogue | Bosses use what she gives away; decides the ending |
| **DDEOK** | 🍡 | Found while exploring; 눈치 overflow | Buys items at the era's shop |
| **점수** | 🎤 | End of each fight | Noraebang-machine score. Bragging only |

### 2.1 ❤️ 체력 — Hearts
- ✅ **Maximum 5 hearts** (10 halves). Shown on screen at all times.
- ✅ Hearts are lost in **halves or wholes**. Most traps cost **½**; a rare few cost **1**. A wrong answer in a fight costs **1** 🟡.
- ✅ **No automatic refill.** Damage from exploring **carries into fights**; damage from fights carries out.
- ✅ **Restored by:**
  - **health items** found while exploring or bought at the 문방구: 🟡 **반창고 +½**, **빨간약 +1**;
  - a **revenge win**, which restores hearts **to full (5)**.
- ❓ An overnight refill between days was suggested and not yet confirmed. Default: **no overnight refill**.
- ✅ 0 hearts = **death** (§3.6 outside fights, §5.5 in fights).

### 2.2 👀 눈치 — Tokens ✅
- **Earned** in dialogue scenes (forced and optional): a good read of the room = **+1 눈치**.
- **Spent** in fights during a blank:
  - **Cross out** one wrong option. **Maximum one cross-out per blank.**
  - **Dodge** one hit after a wrong answer (no heart lost; the attack plays and misses by a hair).
- **Cap: 7.** Act 1's forced scenes award exactly 7 before the first fight.
- **Overflow:** every 눈치 earned while at the cap converts into DDEOK. ❓ Rate.
- Tokens carry over between bosses within an Act. 🟡
- On a fight game over, tokens reset to what she had when the fight started.

### 2.3 🔒 비밀 — Secret Cards ✅
- 보람 holds a hand of **secret cards**: private facts and her dignity.
- **Lost** when she overshares or compromises herself in dialogue (forced or optional). **Cards never come back.** Losing a card already lost costs nothing more.
- A lost card becomes **known** by whoever is in the room (the scene's boss, or a named person).
- **Leak rule:** some people pass on what they hear. Act 1: **함현정 → 현정 엄마** (Boss 3).
- What a known card does: **taunts** in dialogue (§4.4); **loaded blanks** in fights (§5.6).
- Cards still held decide the **ending**. 🟡 They may also vary each Act's ending.

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

### 2.4 🎤 점수 — Noraebang Score ✅
- **점수 = 100 × correct answers ÷ total blanks**, rounded. 100점 gets the fanfare. 🟡 Low scores get era-appropriate insults.

### 2.5 🍡 DDEOK ✅
Governed by the **DDEOK Master Roadmap**. Inside this game:
- DDEOK is shared by all NHMH games.
- **Play modes:** the roadmap defines **on-chain** and **off-chain** modes that **never mix**. Development starts with **off-chain mode only** (virtual DDEOK and virtual items).
- **Earned by:** finding it while exploring (§3.3); 눈치 overflow (§2.2).
- **Spent at** the era's shop (§4.6).
- **Fair-play rule (roadmap):** DDEOK can never be used to cheat through the game — no answers, no lyric blanks, no skipping the Korean.
- **The client never decides what it earned.** In on-chain mode, claims are verified where players can't edit (roadmap Phase 3). Off-chain mode keeps the same interfaces so the switch doesn't need a redesign.
- ❓ Amounts per find, overflow rate and prices.

---

## 3. Game Loop, Maps and Exploration

### 3.1 Loop ✅
```
Act
 └─ Boss loop (×4 in Act 1)
     ├─ Map: dialogue scene 1      → explore · talk · 👀 / 🔒 / 🍡 / ❤️ at stake
     ├─ Map: dialogue scene 2      → same
     ├─ 문방구 (when open)          → spend 🍡
     ├─ Pre-fight map (if needed)  → walk to the fight
     ├─ Noraebang fight (one room) → spend 👀 · lose ❤️ · 🎤 score
     └─ Aftermath beat             → outcome, taunts, year change
```

### 3.2 Maps ✅
- Every dialogue scene takes place in a **map**: side-on, connected rooms (§4.5).
- The same map is reused across days, with characters in different places and different broadcasts on the TV.
- Forced dialogue starts when 보람 approaches the scripted character, or when the script says so. Movement is locked during dialogue.
- **Examinable objects** (no choices) give a line of flavor and unlock an entry in the **era slang codex**.
- **Fights are not maps.** Every fight takes place in **one room**.

### 3.3 Exploration: hidden items and traps ✅
| Type | Examples | Effect |
|---|---|---|
| 🍡 **DDEOK** | — | Currency |
| 📜 **Secret notes** | A scrap of the next boss's song lyrics; the 반장's snitch list; a school map with hiding spots marked; a note in the 출석부 | Useful information: preview fight vocabulary, unlock a dialogue option, reveal spots |
| ❤️ **Health items** | 반창고 (+½), 빨간약 (+1) 🟡 | Restore hearts |
| 🪤 **Traps** | See §3.7 | −½ heart (most) or −1 (rare). Visible gore: blood spray |

- ✅ **Reward : penalty ≈ 6 : 4.** 🟡 "Reward" counts DDEOK, notes and health items together.
- ✅ **Random placement every time the game loads.** Each map has a **pool of candidate spots**; on load, the day's items and traps are dealt into the pool at random. This stops bots and memorized routes.
- 🟡 **Anti-farming budget:** each map-day has a fixed set of items **per save**. Reloading reshuffles **where** the uncollected items are, but never adds new ones; collected items stay collected. *(Without this, reloading would farm DDEOK.)*
- ✅ **No markers.** Nothing shows which spot holds what. Reading the room is the skill.
- 🟡 Per map-day starting point: 1–2 DDEOK, 1 note or health item, 1–2 traps, from a pool of ~10–12 candidate spots.
- 🟡 Secret notes are the best kind of reward when they **teach**: a lyric scrap lets a careful explorer learn the fight's vocabulary early. Notes never give away answers outright (fair-play rule).

### 3.4 Optional conversations ✅
- Classmates and others can be talked to freely, pushing the game toward an open-world RPG feel.
- **Most are flavor**: era jokes, slang, gossip. 🟡 Roughly **1 in 5 has stakes**.
- Stakes cut both ways: a conversation can **earn 눈치** or **cost a secret card**. Every classmate is a potential gossip.
- **No markers** for which conversations matter.
- Each optional conversation's stakes pay out **once per save**.

### 3.5 Pre-fight maps ✅
- Used **only when 보람 has to walk to the fight** (the fight room isn't where the previous scene ended).
- Short. Ends at the door of the fight room.
- **Boss 1 (은주's party):**
  1. **Arrival:** 보람 and 현정 come out of the **elevator**, walk the apartment corridor, 은주 엄마 opens the door; the party is on (guests to talk to, hiding spots and traps: the 장식장 with the 양주, under the sofa, the fridge).
  2. Cut.
  3. **Later:** 보람 comes out of the **bathroom** and walks back, overhearing guests.
  4. **Trigger:** 은주 has the mic for the **장기자랑** — *"이제 장기자랑! 장보람, 너부터."* She picks 〈달님은 계란 후라이〉. 보람 hesitates. *"이 노래 몰라? 이 노래 모르는 애는… 죽어야 돼."* The lights flicker; the fight starts.
- Every boss needs a believable trigger that leads into the song.

### 3.6 Death outside a fight ✅
- 0 hearts while exploring (or anywhere outside a fight) → the **news-anchor game over** (문태식, flat tone).
- ✅ **Restart at the beginning of Scene 01**, without replaying the opening cutscene.
- ❓ What resets: everything back to the state at the start of Scene 01 (hearts, 눈치, cards, DDEOK found in this Act, notes)? Default 🟡: **yes, everything**, which is the survival-horror reading. DDEOK rules in on-chain mode follow the DDEOK spec.

### 3.7 Map 01 — 국민학교 (1979) ✅
```
 ┌───────────────── 2층 (W at 계단) ─────────────────┐
 │  복도 2층 · 빈 교실   (locked Sat · open Mon)    │
 └──────────────────────────────────────────────────┘
 [교문]──[운동장]──[현관]────────[1층 복도]────────────────┐
    │     철봉,     신발장   교무실  1학년 3반 ★  화장실   계단
    │     모래밭,          (W)      (W)        (W)      (W)
    │     이순신 동상
 [골목길]──[전파사]──[문방구]

 ★ 1학년 3반: [조개탄 stove]·[교탁 + 칠판 + 태극기 + TV]·[desks, 2 rows]·[청소도구함]·[door]
```
| Scene | Day | Where |
|---|---|---|
| 00 (classroom part) | Sat 27 Oct | Control starts in the 1층 복도; W at the classroom door; the 반장 writes her name; first choice |
| 01 | Sat 27 Oct, 쉬는 시간 | 1학년 3반; 은주 comes to 보람 after a few seconds or when approached |
| 02 morning | Mon 29 Oct | 1학년 3반 |
| 02 after school | Mon 29 Oct | 현정 follows: 복도 → 현관 → 운동장 → 교문 → 골목길; the 전파사 window TV plays 문태식's funeral announcement |
| 문방구 | after Scene 02 | Opens before the 은주 fight |

**Candidate spots (pool) 🟡:** behind the 조개탄 stove · inside the 청소도구함 · under the 교탁 · a back-row chair · a 신발장 cubby · the 모래밭 · the 철봉 · the 교무실 · the 화장실 · the 이순신 동상 · the 2층 landing (Mon) · behind the 전파사.

**Trap ideas 🟡:**
| Spot | Trap | Damage |
|---|---|---|
| Under the 교탁 | 쥐덫 snaps her fingers, blood spray | ½ |
| A back-row chair | 압정 through the palm | ½ |
| Behind the 조개탄 stove | A live coal tumbles onto her hand | 1 |
| 청소도구함 | A mop handle springs into her eye | ½ |
| 신발장 cubby | A rat bites | ½ |
| 모래밭 | A buried broken 사이다 bottle | 1 |
| 철봉 | The rusty bar snaps; face-first fall | 1 |
| 교무실 | The 사랑의 매 rack falls on her | 1 |
| 화장실 | The ghost asks "빨간 휴지 줄까, 파란 휴지 줄까?" — a choice; the wrong answer hurts | 1 |
| 이순신 동상 | Examine it and the sword swings (school ghost legend) | 1 |
| 전파사 alley | A discarded TV tube implodes | 1 |

The ghost and statue legends are 1980s–90s school folklore, used in 1979 as a deliberate bend. ❓ Final trap list; more ideas welcome. With most traps at ½, the 1-heart traps should be the **rare** ones in the deal.

---

## 4. Dialogue Scenes

### 4.1 Flow ✅
1. Lines play with live 3D characters in the map; advance with **Enter**, **Space** or a click.
2. At a choice, **2–4 options** appear. Select with **W/S + Enter**, or click.
3. The choice resolves its one effect (§9.1) with a clear on-screen cue.
4. Movement is locked while dialogue is on screen.

### 4.2 Choice types ✅
| Type | Effect | Example (Scene 01) |
|---|---|---|
| **Good read** | +1 👀 | "우리 반에 은주는 세 명이나 있잖아." |
| **Overshare** | −1 🔒 (fact card) | "우리 아빠는 소주 세 병 마셔!" → 아빠 주량 |
| **Compromise** | −1 🔒 자존심 | "서울에서 왔어요." (존댓말 to a classmate) |
| **Neutral** | none | "너는?" |
| **Dangerous** 🆕 | −½ or −1 ❤️ | e.g. the 화장실 ghost's question answered wrong |

### 4.3 Timing
- ✅ **Act 1:** no timers on dialogue choices.
- 🟡 Later Acts: timed choices in high-pressure moments.

### 4.4 Conditional lines ✅
- Lines may play only when a card is **lost**, or **taunts** only when the speaker **knows** a card.
- Conditional lines never offer choices and never change state.

### 4.5 Movement and controls ✅
- **Camera:** side-on, *Little Nightmares*-style dollhouse view; follows 보람 with fixed framing per room.

| Key | Action |
|---|---|
| **A / D** | Walk left / right |
| **W / S** | Doors, stairs, rooms or depth layers; up/down in menus |
| **Enter** (or Space) | Talk, interact, search, confirm |
| **Mouse** | Click choices, buttons, 눈치 tokens |

- 🟡 An interaction prompt appears near things 보람 can use, search or talk to (it never reveals what's inside).
- 🟡 Controller later. Phone later, with an on-screen joystick.

### 4.6 The 문방구 (Act 1 shop) ✅
- Each Act has a shop that fits its era. Act 1: the **문방구**, in the 골목길 outside the 교문. Opens after Scene 02.
- **Sells:** **skills**, **clothes**, **빨간약** and **반창고**, and 👀 **눈치** (never above the cap).
- ❓ **Conflict to resolve:** the DDEOK Master Roadmap says DDEOK can never be used to cheat through the game (no answers, no lyric blanks). 눈치 cross-outs remove a wrong option on a lyric blank. **Does selling 눈치 for DDEOK break the fair-play rule?** Options: (a) keep 눈치 for sale, judging that crossing out one option isn't an answer; (b) stop selling 눈치, so it's earned only by reading the room; (c) sell 눈치 that can only **dodge**, not cross out.
- ❓ What skills are; whether clothes have effects. In on-chain mode every buyable item is an NFT (DDEOK roadmap).

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
6. **Wrong, or the attack reaches her:** time unfreezes; −1 ❤️ 🟡 and the attack lands in gore — unless the player spends 👀 to dodge.
- Hearts are the **global hearts** (§2.1): 보람 enters with whatever she has left from exploring.
- 🟡 Act 1 countdown: **5 seconds**; later Acts shorten it.
- Because the music pauses, tracks don't need written-in gaps.

### 5.3 Counters ✅
- Every attack has its own authored counter, either **slapstick** or **gory**.
- 🟡 Verse and chorus lean slapstick; bridge and final chorus lean gory. Every boss's last counter is the biggest payoff.

### 5.4 Winning ✅
| Win | Condition | Outcome |
|---|---|---|
| 🏆 **Revenge win** | No hearts lost during the fight 🟡 | The boss dies a **brutal carnage death caused by their own sloppy mistake**. **Hearts restored to full (5).** |
| 😐 **Survival win** | At least ½ heart left, with hearts lost | The boss is **quelled** and stops bullying 보람. No restore |

- Cross-outs don't break a revenge win. A **dodge** saves the heart, so it doesn't break it either.
- 🟡 The revenge-win condition changed from "all 3 hearts" to "no hearts lost during the fight", because 보람 can now arrive hurt.
- Both wins → 🎤 점수 screen → aftermath beat.

### 5.5 Game over ✅
- The news anchor **문태식** reports 장보람's gruesome death in the same flat tone as the opening assassination. Classmates ignore it.
- 🟡 The headline names the attack that landed the final hit.
- Retry restarts the fight from Phase 1 with the **hearts and 👀 she had when the fight started**.

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
- ✅ **Forward+ renderer** (PC). Needed for the fog and lighting in Style Brief v0.3. Build 001 uses Compatibility and must be switched. 🔍 Confirm which fog and lighting features require Forward+.
- ✅ **Live 3D** characters and rooms, side-on camera (Style Brief v0.3).
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
| `hearts_halves` | int | 0–10 (5 hearts in halves). Global |
| `nunchi` | int | 0–7 |
| `ddeok` | int | 🆕 Shared currency balance |
| `secrets_held` | array of card ids | Starts with the Act's hand |
| `secrets_known_by` | dict: card → person ids | After leaks |
| `leaks` | dict: person → person ids | From `data/secrets/act1_leaks.json` |
| `spawn_seed` | int | 🆕 Per load; deals items and traps into each map's spot pool |
| `collected` | dict: map-day → item ids | 🆕 Items and traps already taken or sprung (per save) |
| `notes` | array of ids | 🆕 Secret notes found |
| `talked` | array of ids | 🆕 Optional conversations whose stakes are spent |
| `owned_items` | array of ids | 🆕 Skills and clothes bought |
| `scores` | dict: boss → 점수 | Best score per boss |
| `outcomes` | dict: boss → "revenge" / "survival" | |
| `progress` | string | Current map / scene / boss |
| `codex` | array | Era slang unlocked |
| `add_nunchi(n)` | method | Applies the cap; overflow → `ddeok` |
| `damage(halves)`, `heal(halves)` | methods | 🆕 Clamp to 0–10; 0 triggers death |
| `lose_secret(card, by = "")` | method | Applies leaks |
| `has_secret(card)`, `knows(person, card)`, `cards_known_by(person)` | methods | |

### 6.8 Project folders ✅
```
res://
  addons/dialogue_manager/
  data/dialogue/   data/songs/   data/secrets/   data/shop/   data/spawns/   # spawns: spot pools and per-day item budgets
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
- **Checkpoint:** the start of Scene 01 is the restart point after a death outside a fight (§3.6).
- The save is **compact**, **versioned** (`save_version`) and separate from code and assets.
- **Modes:** off-chain saves only for now. On-chain and off-chain saves **never mix** (DDEOK Master Roadmap).
- ❓ Act carry-over format; shared save across NHMH games.

---

## 8. UI, Input and Display ✅
- **Platform:** PC (Windows first 🟡; Linux).
- **Input:** keyboard (A/D, W/S, Enter, Space) and mouse. 🟡 Controller later.
- **Display:** live 3D at 1920×1080, Forward+ (Style Brief v0.3).
- **HUD everywhere:** ❤️ hearts (with halves), 👀 눈치, 🍡 DDEOK, 🔒 cards (cards a person knows shown on their side). In fights, the lyric line and options appear on the 반주기 screen.
- ❓ New Korean font.
- 🟡 Korean primary; optional English subtitles via Godot's translation system.

---

## 9. Writer's Rules ✅

### 9.1 Scenes
1. **Every dialogue choice does exactly one thing:** `+1 눈치`, `−1 비밀 card`, `−½ or −1 ❤️`, or nothing.
2. Each forced choice point should offer one good-read (눈치) answer.
3. **No placeholder names.** Every speaking character has a real name.
4. **No real names.** Satirical fictional names only.
5. **Violence wherever it fits**, in any part of the game. Over-the-top, never apologized for.
6. Facts the user has confirmed or deliberately bent are noted in the script file, not re-checked.

### 9.2 Songs
1. **Every blank does exactly one thing:** right = counter, wrong = −1 heart.
2. Distractors must be plausible and teach something.
3. Blanks get harder phase by phase.
4. Lyrics never reference a boss's real life or 보람's secrets.

### 9.3 Maps
1. Every map has a **spot pool** large enough for random dealing, with a reward:penalty mix of about 6:4.
2. Hidden spots and traps fit the place and the era.
3. Most traps cost ½ heart; 1-heart traps are rare.
4. Secret notes help or teach; they never hand over answers.

---

## 10. Open Questions
1. 눈치 for sale vs. the DDEOK fair-play rule (§4.6).
2. Overnight heart refill between days: yes or no (§2.1). Default no.
3. What resets after a death outside a fight (§3.6). Default everything.
4. Health item amounts; fight damage per wrong answer (§2.1).
5. Whether "reward" in the 6:4 ratio includes notes and health items (§3.3).
6. The anti-farming budget per save (§3.3).
7. DDEOK amounts, overflow rate, 문방구 prices.
8. What skills are; whether clothes have effects.
9. Final trap list for Map 01 (§3.7).
10. Music tool: ACE-Step 1.5 or Suno.
11. Act carry-over; shared NHMH save.
12. New Korean font.
