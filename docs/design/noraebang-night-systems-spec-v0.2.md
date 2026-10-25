# Noraebang Night — Systems Spec

*Version 0.2 · Drafted 24 October 2026 · Supersedes v0.1 (21 October 2026)*
*Applies to: the whole game. Act 1 values given where they differ.*

> **Document rules**
> - Production document. Changes are made by issuing a **new version**; earlier versions stay unchanged.
> - What is actually built, and any deviation from this spec, is recorded in the **project logs**.
> - ✅ decided · 🟡 proposed default, adjust in session · ❓ open · 🔍 verify

### What changed since v0.1
| § | Change |
|---|---|
| 2.3 | Act 1 hand grows to 7 cards (adds 엄마 월급, 아빠 주량). Losing a card already lost costs nothing. |
| 2.3, 6.7 | **Leak rule:** a card told to certain people spreads to others (현정 → 현정 엄마). |
| 2.3, 5.6 | **Secret attacks removed.** Songs never change their lyrics. Lost cards now make blanks **loaded** and add **taunts**. |
| 4.4 | Conditional dialogue lines based on lost or known cards. |
| 5.4 | **Two win types:** revenge win and survival win. |
| 5.7 | New section: **songs** — songs are songs, topic categories, who picks the song, originality. |
| 6.1 | Engine **Godot 4.7.2** (build 001 used 4.7.1). Dialogue Manager **4.1.0**. |
| 6.4 | Song file format updated: loaded blanks, outcomes, no secret-attack lyrics. |
| 8 | Display follows the approved Style Brief v0.1: 1920×1080 renders, pixel-art settings and pixel font dropped. |
| 9 | New section: **writer's rules** for scenes and songs. |

---

## 1. Design Goals ✅

1. **Easy to understand.** A new player understands every number on screen within the first scene.
2. **Easy to maintain.** The same rules run from 1979 to 2030. New scenes and songs are **data, not code**.
3. **The two halves feed each other.** Playing the social scenes well makes the fights easier.
4. **The long game matters.** What 보람 gives away follows her to the ending.

---

## 2. The Scoring System ✅

Three resources, each with one job and one place it changes. Plus one score for show.

| Resource | Icon | Where it changes | What it does |
|---|---|---|---|
| **체력** (hearts) | ❤️ | Noraebang fights only | Survive this fight |
| **눈치** | 👀 | Earned in dialogue, spent in fights | Makes fights easier |
| **비밀** (secret cards) | 🔒 | Lost in dialogue | Bosses use what she gives away; decides the ending |
| **점수** | 🎤 | End of each fight | Noraebang-machine score. Bragging only |

### 2.1 ❤️ 체력 — Hearts ✅
- **3 hearts per boss fight.** Reset to 3 at the start of every fight.
- Wrong answer or timeout → **−1 heart** and the attack lands in full gore.
- 0 hearts → **game over** (§5.5) → retry the fight.
- Hearts do not exist outside fights.

### 2.2 👀 눈치 — Tokens
- ✅ **Earned** in dialogue scenes: a good read of the room = **+1 눈치**.
- ✅ **Spent** in fights, by tapping a token during a blank:
  - **Cross out** one wrong option.
  - **Dodge** one hit after a wrong answer (no heart lost; the attack plays and misses by a hair).
- 🟡 Cap: **5 tokens**. Earned tokens beyond the cap are lost. *(Act 1 can offer up to 7 before the first fight: 1 in Scene 00, 3 in Scene 01, 3 in Scene 02. With a cap of 5, a perfect player loses 2.)*
- 🟡 Tokens carry over between bosses within an Act.
- ✅ On game over, tokens reset to what she had **when the fight started**.

### 2.3 🔒 비밀 — Secret Cards
- ✅ 보람 holds a hand of **secret cards**: private facts and her dignity.
- ✅ **Lost** when she overshares or compromises herself in dialogue. **Cards never come back.**
- ✅ Losing a card she has already lost **costs nothing more**.
- ✅ A lost card becomes **known** by whoever is in the room (the scene's boss, or a named person).
- ✅ **Leak rule:** some people pass on what they hear. A card known by a leaker becomes known by everyone they leak to. Act 1: **함현정 → 현정 엄마** (Boss 3).
- ✅ What a known card does:
  - **Dialogue:** the knower gets extra **taunts** (§4.4).
  - **Fights:** 🟡 the boss gets **loaded blanks** (§5.6).
- ✅ Cards still held decide the **ending** (whole game). 🟡 They may also vary each Act's ending.

**Act 1 hand ✅**
| Card id | Card | What it guards |
|---|---|---|
| `dad_country` | 아빠 나라 | Her father's country |
| `dad_story` | 아빠 이야기 | Her father's war service and why he can't go home |
| `our_home` | 우리 집 | Her home, food and family life |
| `mom_job` | 엄마 일 | Her mother's job |
| `mom_salary` | 엄마 월급 | How much her mother earns |
| `dad_drinking` | 아빠 주량 | How much her father drinks |
| `pride` | 자존심 | Her dignity: lost by laughing along, accepting humiliation, bowing to a peer, or apologizing for existing |

✅ 아빠 나라 is **one card among many**; the satire targets Korean nosiness in general, not her ethnicity.
❓ Later Acts add new cards (e.g. 나이, 결혼, 월급, 학벌, 정치 성향). Whether Act 1 cards carry into Act 2 depends on save carry-over (§7).

### 2.4 🎤 점수 — Noraebang Score ✅
- Shown at the end of every fight, styled after a real noraebang machine.
- **점수 = 100 × correct answers ÷ total blanks**, rounded.
- 100점 gets the fanfare. 🟡 Low scores get era-appropriate insults from the machine.
- Affects nothing else. 🟡 May unlock codex entries or cosmetic extras.

---

## 3. Game Loop ✅

```
Act
 └─ Boss loop (×4 in Act 1)
     ├─ Dialogue scene 1      → earn 👀 / lose 🔒
     ├─ Dialogue scene 2      → earn 👀 / lose 🔒
     ├─ Noraebang fight       → spend 👀 / lose ❤️ / 🎤 score
     └─ Aftermath beat        → outcome, taunts, year change
```

---

## 4. Dialogue Scenes

### 4.1 Flow ✅
1. Lines play with character renders; tap to advance.
2. At a choice, **2–4 options** appear as tappable buttons.
3. The choice resolves its one effect (§9.1) with a clear on-screen cue:
   - +1 눈치 → eye icon flies to the token bar.
   - −1 비밀 → the card cracks and flips to the knower's side of the screen.
4. Branches can rejoin; most scenes have one exit.

### 4.2 Choice types ✅
| Type | Effect | Example (Scene 01) |
|---|---|---|
| **Good read** | +1 👀 | "우리 반에 은주는 세 명이나 있잖아." |
| **Overshare** | −1 🔒 (fact card) | "우리 아빠는 소주 세 병 마셔!" → 아빠 주량 |
| **Compromise** | −1 🔒 자존심 | "서울에서 왔어요." (존댓말 to a classmate) |
| **Neutral** | none | "너는?" |

### 4.3 Timing
- ✅ **Act 1:** no timers.
- 🟡 Later Acts: timed choices in high-pressure moments; timeout counts as the worst option.

### 4.4 Conditional lines ✅
- A scene may include lines that play only when a card is **lost** (e.g. Scene 01: 은주 mocks the apology to the 반장 if 자존심 is gone).
- A scene may include **taunts** that play only when the speaker **knows** a card (e.g. Scene 02: one taunt each for 아빠 나라, 아빠 주량, 엄마 월급, 자존심).
- Conditional lines never offer choices and never change state.

---

## 5. Noraebang Fights

### 5.1 Structure
- ✅ One original song per boss, in **four phases**:

| Phase | Section | Blanks 🟡 | Blank difficulty | Attack intensity |
|---|---|---|---|---|
| 1 | Verse | 3 | Easiest | Nasty |
| 2 | Chorus | 3 | Easy | Worse |
| 3 | Bridge | 2 | Moderate | Rule-breaking |
| 4 | Final chorus | 2 | Hardest | Signature carnage |

🟡 **10 blanks per song** in Act 1. *(v0.1's extra secret-attack blanks are removed; see §5.6.)*

### 5.2 A single blank, moment to moment
1. ✅ The lyric line scrolls on the arena's 반주기 screen with one blank and its options. 🟡 Act 1: **3 options**.
2. ✅ The boss **winds up the attack** while the line approaches. The wind-up is the timer. 🟡 Act 1: **5 seconds**; later Acts shorten it.
3. ✅ The player taps an option before the attack lands. They may spend 👀 first.
4. ✅ **Right:** the counter plays; the song continues.
5. ✅ **Wrong or too slow:** −1 ❤️, the attack lands in gore — unless the player spends 👀 to dodge.
6. ❓ Does the music **pause** during a wind-up, or are the gaps **written into the music**? Decide once the first track exists.

### 5.3 Counters ✅
- Every attack has its own authored counter, either **slapstick** or **gory**.
- 🟡 Guideline: verse and chorus lean slapstick; bridge and final chorus lean gory. Every boss's last counter is the biggest payoff of the fight.

### 5.4 Winning — two win types ✅
| Win | Condition | Outcome |
|---|---|---|
| 🏆 **Revenge win** | No mistakes and all 3 hearts | The boss dies a **brutal carnage death caused by their own sloppy mistake** |
| 😐 **Survival win** | At least 1 heart left, with mistakes | The boss is **quelled** and stops bullying 보람 |

- 🟡 A 눈치 **cross-out** does not count as a mistake. A 눈치 **dodge** does (a wrong answer was given).
- Both wins → 🎤 점수 screen → aftermath beat.

### 5.5 Game over ✅
- The news anchor (**문태식**) reports 장보람's gruesome death in the same flat tone as the opening assassination. Classmates ignore it.
- 🟡 The headline names the attack that landed the final hit.
- Retry restarts the fight from Phase 1 with 3 hearts and pre-fight 👀.

### 5.6 Known cards in fights 🟡
✅ **Songs never change their lyrics** because of lost cards. Proposed effects instead:
- **Loaded blank:** for each card the boss knows, one predefined blank gets **4 options instead of 3**, and its attack lands with a nastier flourish.
- **Aftermath taunts:** the boss's knowledge shows in the aftermath beat, not in the song.
- Each song defines which blank each card loads and the extra option (see §6.4).

### 5.7 Songs ✅
- **Songs are songs.** Bosses never sing about their real lives. Privacy and 눈치 live in dialogue scenes, not lyrics.
- Songs are strange, playful art pieces. **Loose resonance** with the boss is fine if it's well done; **pure randomness** is fine if the song is good.
- **Topic categories** (vocabulary domains; concrete early, abstract later): Food Love Songs · Animal Confessions · Weather Romance · Object Laments · Body Parts · Space & Fantasy · Numbers & Counting · Fake Jingles.
- **Who picks:** the **boss** picks the song. 🟡 In certain later Acts the **player** picks from the 반주기 songbook (two songs from different categories).
- **Original songs only.** No parodies of copyrighted melodies. Genre parodies, title or hook riffs, and public-domain melodies (e.g. 민요) are fine.
- ❓ Music generation tool: **ACE-Step 1.5** (MIT, runs on the user's Intel Arc B580) or **Suno** (paid plan).
- Each song is delivered as a **vocal** and an **instrumental** track, with timestamps for every blank line.

---

## 6. Godot Data Pipeline

### 6.1 Engine and addons
- ✅ **Godot 4.7.2** (latest stable, confirmed 24 Oct 2026). Build 001 was made with 4.7.1; it opens in 4.7.2 unchanged 🔍 (confirm on first open).
- ✅ **Dialogue Manager 4.1.0** by Nathan Hoad (MIT). Requires Godot 4.6+.
- ✅ Both licences are compatible with AGPL-3.0 code.

### 6.2 Principle ✅
> **Scenes and songs are data files. Code runs any of them.**
> Adding a boss = a `.dialogue` file per scene, a song file, art and audio. No new code.
> Stage directions in `.dialogue` files (e.g. `$> stage("classroom")`) call methods on the scene that plays them.

### 6.3 Dialogue files (`.dialogue`) ✅
Dialogue Manager format. Writers edit text, not code. Choices change state through the `GameState` autoload. Syntax verified against Dialogue Manager 4.1.0 in build 001.

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

# Card told to a specific person (leak rule applies)
$> GameState.lose_secret("our_home", "hyunjeong")

# Conditional lines (§4.4)
if not GameState.has_secret("pride")
	은주: 아까 반장한테 "미안해…" 했지?
if GameState.knows("eunju", "dad_drinking")
	은주: 너희 아빠는 오지 마. 소주 세 병 마시잖아.
=> END
```

### 6.4 Song files 🟡
One JSON file per song in `data/songs/`. Example (abridged) for 〈달님은 계란 후라이〉:

```json
{
  "id": "eunju_dalnim",
  "title": "달님은 계란 후라이",
  "boss": "eunju",
  "audio_vocal": "res://audio/songs/eunju_dalnim_vocal.ogg",
  "audio_instrumental": "res://audio/songs/eunju_dalnim_inst.ogg",
  "phases": [
    {
      "phase": 1,
      "section": "verse",
      "blanks": [
        {
          "n": 1,
          "time": 12.4,
          "windup": 5.0,
          "line": "하얀 흰자 가운데 ___ 노른자",
          "options": ["노란", "파란", "까만"],
          "answer": "노란",
          "teaches": "Colour adjectives",
          "attack": "booger_flick",
          "counter": "booger_flick_slapstick"
        }
      ]
    }
  ],
  "loaded": [
    { "card": "dad_country", "blank": 4, "extra_option": "설탕" },
    { "card": "mom_salary",  "blank": 6, "extra_option": "적어요" },
    { "card": "dad_drinking","blank": 9, "extra_option": "마시고 싶어요" }
  ],
  "outcomes": {
    "revenge":  "res://data/dialogue/boss_01_eunju_revenge.dialogue",
    "survival": "res://data/dialogue/boss_01_eunju_survival.dialogue",
    "game_over_headlines": {
      "color_tv_drop": "…생일 파티에서 컬러 TV에 깔려 사망했습니다.",
      "default": "…생일 파티에서 사망했습니다."
    }
  }
}
```
- Option order is shuffled at runtime; `answer` names the correct option.
- `time` values come from the track's lyric timestamps.

### 6.5 Attacks and counters ✅
- Each attack and counter is a named **animation set** (`booger_flick`, `…_slapstick`, `…_gory`).
- Song files reference attacks by name, so attacks can be reused or swapped without editing code.

### 6.6 Music sync ✅
- Blank timing reads the song's **playback position**, corrected for **audio output latency** (Godot's "Sync the gameplay with audio and music" guide).
- Tap answers don't need rhythm-game precision; the wind-up window absorbs small timing errors.

### 6.7 Global state (`GameState` autoload)
| Variable / method | Type | Notes |
|---|---|---|
| `hearts` | int | 0–3, fights only |
| `nunchi` | int | 0–5 (🟡 cap) |
| `secrets_held` | array of card ids | Starts with the Act's hand |
| `secrets_known_by` | dict: card → person ids | Who knows what (after leaks) |
| `leaks` | dict: person → person ids | 🆕 Loaded from `data/secrets/act1_leaks.json`. Act 1: `{"hyunjeong": ["hyunjeong_mom"]}` |
| `scores` | dict: boss → 점수 | Best score per boss |
| `outcomes` | dict: boss → "revenge" / "survival" | 🆕 |
| `progress` | string | Current scene / boss |
| `codex` | array | Era slang unlocked |
| `lose_secret(card, by = "")` | method | `by` defaults to the current boss; applies leaks |
| `has_secret(card)` | method | Built in build 001 |
| `knows(person, card)` | method | 🆕 For taunts and loaded blanks |
| `cards_known_by(person)` | method | Built in build 001 |

### 6.8 Project folders ✅ (as built)
```
res://
  addons/dialogue_manager/
  data/dialogue/      # .dialogue files, one per scene
  data/songs/         # song JSON files
  data/secrets/       # card definitions and leak tables per Act
  audio/songs/  audio/sfx/
  art/characters/  art/arenas/  art/attacks/  art/fonts/
  scenes/             # opening, dialogue box, HUD, fight player
  scripts/            # GameState, loaders, fight logic
  tests/              # headless tests, capture tool
  docs/               # roadmaps, design, scripts, songs, logs (ignored by Godot)
```

---

## 7. Saving
- ✅ Autosave at the start of every dialogue scene and fight. Save holds the full `GameState`.
- ❓ **Act carry-over:** each Act is a standalone release. Option: export a carry-over code or file at the end of an Act (cards, known-by, totals) that the next Act imports. Players without one start with a default hand.

---

## 8. UI, Input & Display
- ✅ **Input:** mouse click or touch tap only. All targets large enough for phones.
- ✅ **Display** (Style Brief v0.1 §9): characters and rooms are 3D renders at **1920×1080**. The 640×360 pixel-art viewport and the Galmuri pixel font are dropped. ❓ New Korean font chosen in a later session. *(Not yet changed in the build; waits for the style test.)*
- ✅ **HUD in fights:** ❤️ hearts, 👀 tokens (tappable), lyric line and options on the 반주기 screen, boss.
- ✅ **HUD in dialogue:** 👀 tokens and 🔒 cards; cards a person knows shown on their side.
- 🟡 Text: Korean primary; optional English subtitles via Godot's translation system.
- ❓ Which platforms ship first: PC, Android, iOS, web.

---

## 9. Writer's Rules ✅

### 9.1 Scenes
1. **Every dialogue choice does exactly one thing:** `+1 눈치`, `−1 비밀 card`, or nothing.
2. Each choice point should offer one good-read (눈치) answer.
3. **No placeholder names.** Every speaking character has a real name.
4. **No real names.** Satirical fictional names only.
5. No violence outside noraebang fights; no sexual content, ever.
6. Facts the user has confirmed or deliberately bent (e.g. home 반주기 in 1979) are noted in the script file, not re-checked.

### 9.2 Songs
1. **Every blank does exactly one thing:** right = counter, wrong = −1 heart.
2. Distractors must be plausible and teach something.
3. Blanks get harder phase by phase.
4. Lyrics never reference a boss's real life or 보람's secrets.

---

## 10. Open Questions
1. 👀 cap and carry-over values (§2.2), given up to 7 tokens before the first fight.
2. Loaded-blank rule (§5.6): approve, change or replace.
3. Whether a 눈치 dodge breaks a revenge win (§5.4).
4. Music pauses vs. written-in gaps (§5.2).
5. Music tool: ACE-Step 1.5 or Suno (§5.7).
6. Act carry-over format (§7).
7. New Korean font (§8).
8. Which platforms ship first; English subtitles at launch or later (§8).
