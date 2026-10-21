# Noraebang Night — Systems Spec

*Version 0.1 · Drafted 21 October 2026*
*Brand: <니가 한국어 못해>*
*Applies to: the whole game. Act 1 values given where they differ.*

> **Document rules**
> - This is a production document, not a roadmap. Changes are made by issuing a **new version** (v0.2, v0.3…); earlier versions are kept unchanged.
> - What is actually built, and any deviation from this spec, is recorded in the **project logs**.
> - ✅ decided · 🟡 proposed default, adjust in session · ❓ open · 🔍 verify against current docs before building

---

## 1. Design Goals

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
| **비밀** (secrets) | 🔒 | Lost in dialogue (and fights, §2.3) | Bosses use what she gives away; decides the ending |
| **점수** | 🎤 | End of each fight | Noraebang-machine score. Bragging only |

### 2.1 ❤️ 체력 — Hearts ✅
- **3 hearts per boss fight.** Reset to 3 at the start of every fight.
- Wrong answer or timeout → **−1 heart** and the attack lands in full gore.
- 0 hearts → **game over** (news-anchor gag, §5.5) → retry the fight.
- Hearts do not exist outside fights.

### 2.2 👀 눈치 — Tokens
- **Earned** in dialogue scenes: a good read of the room = **+1 눈치**.
- **Spent** in fights, by tapping a token during a blank. Two uses:
  - **Cross out** one wrong option.
  - **Dodge** one hit after a wrong answer (no heart lost; the attack still plays, and misses by a hair).
- 🟡 Cap: **5 tokens**. Earned tokens beyond the cap are lost.
- 🟡 Tokens carry over between bosses within an Act.
- On game over, tokens reset to what she had **when the fight started**.

### 2.3 🔒 비밀 — Secret Cards
- 보람 holds a hand of **secret cards**: private facts and her dignity.
- **Lost** when she overshares or compromises herself.
- A lost card is **known** by the people around her. Bosses who know a card get:
  - an extra **taunt** in their dialogue, and
  - one extra **"secret attack"** blank in their fight, built around that information.
- Cards never come back. Cards still held decide the **ending** (whole game) and the **Act ending variation** 🟡.

**Act 1 cards 🟡**
| Card | What it guards | Bosses most likely to pry |
|---|---|---|
| 🇪🇹 아빠 나라 | Her father's country | 김은주, 홍대중 |
| 🎖️ 아빠 이야기 | Her father's war service and why he can't go home | 홍대중 |
| 🏠 우리 집 | Her home, food and family life | 정정훈 |
| 👩 엄마 일 | Her mother's job | 현정 엄마 |
| 🛡️ 자존심 | Her dignity — lost by laughing along, accepting a humiliating role, or apologizing for existing | All |

Later Acts add new cards (e.g. 나이, 결혼, 월급, 학벌, 정치 성향). ❓ Whether Act 1 cards carry into Act 2 depends on save carry-over (§7).

### 2.4 🎤 점수 — Noraebang Score
- Shown at the end of every fight, styled after a real noraebang machine.
- **점수 = 100 × correct answers ÷ total blanks**, rounded.
- 100점 gets the fanfare. 🟡 Low scores get era-appropriate insults from the machine.
- Affects nothing else. 🟡 May unlock codex entries or cosmetic extras.

### 2.5 The writer's rules ✅
Every scene must follow these. They keep everything balanceable.

> **Every dialogue choice does exactly one thing:** `+1 눈치`, `−1 비밀 card`, or nothing.
> **Every blank does exactly one thing:** right = counter, wrong = −1 heart.

---

## 3. Game Loop

```
Act
 └─ Boss loop (×4 in Act 1)
     ├─ Dialogue scene 1      → earn 👀 / lose 🔒
     ├─ Dialogue scene 2 (optional)
     ├─ Noraebang fight       → spend 👀 / lose ❤️ / 🎤 score
     └─ Aftermath beat        → consequences, year change
```

---

## 4. Dialogue Scenes

### 4.1 Flow
1. Lines play with character portraits; tap to advance.
2. At a choice, **2–4 options** appear as tappable buttons.
3. The choice resolves its one effect (§2.5) with a clear on-screen cue:
   - +1 눈치 → eye icon flies to the token bar.
   - −1 비밀 → the card cracks and flips to the boss's side of the screen.
4. Branches can rejoin; most scenes have one exit.

### 4.2 Choice types
| Type | Effect | Example (김은주: "너 어디서 왔어?") |
|---|---|---|
| **Good read** | +1 👀 | "서울에서 왔어." — true and gives nothing away |
| **Overshare** | −1 🔒 (아빠 나라) | "우리 아빠는 에티오피아 사람이야." |
| **Compromise** | −1 🔒 (자존심) | Laughing along when the class mocks her name |
| **Neutral** | none | A safe but forgettable answer |

### 4.3 Timing
- **Act 1:** no timers. Players learn the system first.
- 🟡 Later Acts: timed choices in high-pressure moments; timeout counts as the worst option.

---

## 5. Noraebang Fights

### 5.1 Structure
- One original song per boss, in **four phases**:

| Phase | Section | Blanks 🟡 | Blank difficulty | Attack intensity |
|---|---|---|---|---|
| 1 | Verse | 3 | Easiest | Nasty |
| 2 | Chorus | 3 | Easy | Worse |
| 3 | Bridge | 2 | Moderate | Rule-breaking |
| 4 | Final chorus | 2 | Hardest | Signature carnage |
| + | Secret attacks | 1 per lost card the boss knows | Moderate | Personal |

🟡 About **10 blanks per song** in Act 1.

### 5.2 A single blank, moment to moment
1. The lyric line appears with one blank and **2–4 options** (Act 1: 3 options 🟡).
2. The boss **winds up the attack** while the line approaches. The wind-up is the timer.
3. The player taps an option before the attack lands. They may spend 👀 first.
4. **Right:** the counter plays; the song continues.
5. **Wrong or too slow:** −1 ❤️, the attack lands in gore — unless the player spends 👀 to dodge.

🟡 Wind-up length in Act 1: **5 seconds**, generous for TOPIK 2. Later Acts shorten it.

### 5.3 Counters ✅ — gory and slapstick
- Every attack is authored with its own counter, which can be **slapstick** (the chalk bounces back into the teacher's mouth) or **gory** (the boss gets the full treatment).
- 🟡 Guideline: verse and chorus lean slapstick; bridge and final chorus lean gory. Every boss's last counter is the biggest payoff of the fight.

### 5.4 Winning
- Survive all blanks with at least 1 heart.
- 🎤 점수 screen → aftermath beat.

### 5.5 Game over ✅
- The news anchor reports 장보람's gruesome death in the same flat tone as the opening assassination. Classmates ignore it.
- 🟡 A unique headline per boss.
- Retry restarts the fight from Phase 1 with 3 hearts and pre-fight 👀.

---

## 6. Godot Data Pipeline

### 6.1 Engine and addons 🔍
- **Godot 4.6 or later** (MIT licence). Confirm the latest stable release at build start.
- **Dialogue Manager 4** by Nathan Hoad (MIT) for dialogue scenes. Requires Godot 4.6+.
- Both licences are compatible with AGPL-3.0 code.

### 6.2 Principle
> **Scenes and songs are data files. Code runs any of them.**
> Adding a boss = writing a `.dialogue` file and a song file, plus art and audio. No new code.

### 6.3 Dialogue files (`.dialogue`)
Written in Dialogue Manager's script-like format. Writers edit text, not code. Choices change game state through a global `GameState`.

Illustrative sketch 🔍 (check syntax against Dialogue Manager's current docs):

```
~ eunju_scene_1

은주: 너 어디서 왔어?
- 서울에서 왔어.
	do GameState.add_nunchi(1)
	은주: ...흥.
- 우리 아빠는 에티오피아 사람이야.
	do GameState.lose_secret("dad_country")
	은주: 에티오피아? 그게 어디야? 아프리카?
- 너는?
	은주: 나? 우리 집엔 컬러 TV 있어.
=> END
```

### 6.4 Song files
One file per song. 🟡 Authored as **JSON** for easy editing, loaded into a Godot resource at runtime.

```json
{
  "id": "eunju_birthday",
  "title": "생일 축하해, 나만",
  "boss": "eunju",
  "audio": "res://audio/songs/eunju_birthday.ogg",
  "phases": [
    {
      "phase": 1,
      "section": "verse",
      "blanks": [
        {
          "time": 12.4,
          "windup": 5.0,
          "line": "오늘은 ___ 생일이야",
          "options": ["나의", "너의", "우리"],
          "answer": "나의",
          "teaches": "possessive 나의 / 내",
          "attack": "candle_flamethrower",
          "counter": "candle_flamethrower_slapstick"
        }
      ]
    }
  ],
  "secret_attacks": [
    {
      "requires_card": "dad_country",
      "line": "너네 아빠 나라엔 ___ 없지?",
      "options": ["생일", "케이크", "TV"],
      "answer": "TV",
      "attack": "color_tv_drop",
      "counter": "color_tv_drop_gory"
    }
  ]
}
```

### 6.5 Attacks and counters
- Each attack and counter is a named **animation set** (`candle_flamethrower`, `..._slapstick`, `..._gory`).
- Song files reference attacks by name, so one attack can be reused or swapped without editing code.

### 6.6 Music sync
- Blank timing reads the song's **playback position**, corrected for **audio output latency**, following Godot's "Sync the gameplay with audio and music" guide.
- Tap-based answers don't need rhythm-game precision. The wind-up window absorbs small timing errors.

### 6.7 Global state (`GameState` autoload)
| Variable | Type | Notes |
|---|---|---|
| `hearts` | int | 0–3, fights only |
| `nunchi` | int | 0–5 |
| `secrets_held` | array of card ids | Starts with the Act's hand |
| `secrets_known_by` | dict: card → boss ids | Who knows what |
| `scores` | dict: boss → 점수 | Best score per boss |
| `progress` | string | Current scene / boss |
| `codex` | array | Era slang unlocked |

### 6.8 Suggested project folders 🟡
```
res://
  addons/dialogue_manager/
  data/dialogue/      # .dialogue files, one per scene
  data/songs/         # song JSON files
  data/secrets/       # card definitions per Act
  audio/songs/
  audio/sfx/
  art/characters/
  art/arenas/
  art/attacks/
  scenes/             # Godot scenes: dialogue player, fight player, menus
  scripts/            # GameState, loaders, fight logic
```

---

## 7. Saving

- Autosave at the start of every dialogue scene and fight.
- Save holds the full `GameState`.
- ❓ **Act carry-over:** each Act is a standalone release. Option: export a small "carry-over code" or file at the end of an Act (secret cards, totals) that the next Act can import. Players without one start with a default hand.

---

## 8. UI & Input

- **Input:** mouse click or touch tap only. All targets large enough for phones.
- **HUD in fights:** ❤️ hearts (top left), 👀 tokens (tappable, bottom), lyric line and options (centre), boss (right).
- **HUD in dialogue:** 👀 tokens and 🔒 cards visible; the cards a boss knows are shown on the boss's side of the screen.
- **Text:** Korean primary. 🟡 Optional English subtitles via Godot's translation system.
- **Platforms:** PC, Android, iOS and web from one project. ❓ Which ship first.

---

## 9. Open Questions

1. 👀 cap and carry-over values (§2.2)
2. Final Act 1 secret cards (§2.3)
3. Blanks per phase and wind-up length (§5.1, §5.2)
4. Act carry-over format (§7)
5. Which platforms ship first (§8)
6. English subtitles at launch or later (§8)
