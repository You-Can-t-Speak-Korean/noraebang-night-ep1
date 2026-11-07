# Song Sheet Template v0.2
*Noraebang Night · one template, one sheet per song · Supersedes v0.1 (28 Oct 2026)*

> **How to use**
> - Copy everything below the line into a new file named `songsheet-{NN}-{boss}-{slug}-v0.1.md` (e.g. `songsheet-02-jeonghun-maeui-sarang-v0.1.md`).
> - **Order of work:**
>   1. Write §1 and §4 (WRITE).
>   2. Native-speaker review.
>   3. Paste §2 and §3 into Suno.
>   4. Pick a take.
>   5. Time the blanks with `--mark-song` (§7).
>   6. Check with `--check-song`.
> - **Keep the layout exactly as it is.** The game reads this file. In particular:
>   - §1 must be the **first code block** in the file;
>   - §4 keeps its 8 columns and the phase names Verse / Chorus / Bridge / Final;
>   - §5 rows keep `#n` in the second column;
>   - the game-over line keeps the `> *"…"*` format.
> - Delete these instructions and the `{…}` placeholders when you fill it in.
> - Markers: ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

### What changed since v0.1
- The order follows the game's sheet reader: game lyrics first, then the Suno blocks.
- Added the song timing workflow (`--mark-song`) and the labels file. Blank times live only in the labels file.
- Added the fight rules as built (Song Sheet 01 v0.3): no dodges, the revenge and survival rules, results after the last sung line.
- Added the Suno lessons: no names, no parentheses, no blank markers in the Suno lyrics.
- Added the shared sound effects (screams).
- The rights checklist is removed.

---

# Song Sheet {NN} — 〈{Title}〉

*v0.1 · {date}*
*Act {n}: {act name} · Boss {n}: {boss full name}*

> Production document. Changes are made by issuing a new version.
> Native-speaker review: ☐ not yet / ✅ passed ({date})
> ✅ decided · 🟡 proposed · ❓ open · 🔍 verify

## 0. Overview

| Field | Value |
|---|---|
| Boss | {name} |
| Arena | {where the fight happens, era props} |
| Singer | {who sings the game track} ✅ |
| Intro / outro | {who speaks them, and the lines} |
| Topic category | {Food Love Songs · Animal Confessions · Weather Romance · Object Laments · Body Parts · Space & Fantasy · Numbers & Counting · Fake Jingles} |
| Genre | {genre and era} |
| Tempo / key | {BPM, key, section changes} |
| Register | {speech level of the lyrics} |
| Language focus | {grammar and vocabulary the blanks teach} |

### Song arc
| Phase | What happens in the song | What happens in the room |
|---|---|---|
| 1 Verse | {…} | {nasty} |
| 2 Chorus | {…} | {worse} |
| 3 Bridge | {…} | {rule-breaking} |
| 4 Final chorus | {…} | {signature carnage} |

---

## 1. Game Lyrics  (the game reads this block; keep it the first code block)

`⟦ ⟧` = blank (answer shown) · `[n]` = blank number, at the end of the line

```
〈{Title}〉

[Intro — spoken]
{Speaker}: {spoken intro line}

[Phase 1 — Verse]
{line}
{line with ⟦answer⟧ in it}                          [1]

[Phase 2 — Chorus]
{line}
{line with ⟦answer⟧ in it}                          [4]

[Phase 3 — Bridge]
{line with ⟦answer⟧ in it}                          [7]
({stage direction, hidden in the game})

[Phase 4 — Final chorus]
{line with ⟦answer⟧ in it}                          [9]

[Outro — spoken]
{Speaker}: {spoken outro line}
```

**Rules**
- 10 blanks: 3 in the verse, 3 in the chorus, 2 in the bridge, 2 in the final chorus. One blank per line.
- Section headers exactly as shown: `[Intro …]`, `[Phase n — Verse | Chorus | Bridge | Final chorus …]`, `[Outro …]`. Anything after a second `—` is a note.
- Intro and outro lines are `Speaker: text`. A line starting with `(` is a stage direction: it is hidden in the game.
- Songs are original. Lyrics never mention the boss's real life or 보람's secrets.

---

## 2. Suno — Styles  (paste exactly this into the Styles box)

```
{BPM} BPM, {genre and era}, {mood}, {lead instruments}, {rhythm, bass, production}, {vocal: age, gender, delivery}, Korean lyrics, {section changes, e.g. bridge half-time}
```

**Rules:** BPM first. One line, comma-separated. No character names, no lyrics. 🔍 Check Suno's current length limit for the box.

---

## 3. Suno — Lyrics  (paste exactly this into the Lyrics box)

```
[Intro]
{spoken intro words only}

[Verse]
{every line of §1 Phase 1, with the blank words filled in}

[Chorus]
{…}

[Bridge]
{…}

[Final Chorus]
{…}

[Outro]
{spoken outro words only}
```

**Rules**
- This is §1 with the blanks filled in, minus everything Suno would read out loud:
  - **no speaker names** (Suno said them);
  - **no parentheses** (Suno sang "(the lights go out)");
  - no `⟦ ⟧`, no `[n]`, no notes.
- Only the section tags in `[brackets]` stay.
- Every sung word must match §1 exactly; the timing labels are checked against §1.

---

## 4. Blank Table  (the game reads this table; keep the 8 columns)

| # | Phase | Line | Options | Answer | Teaches | Attack (wrong) | Counter (right) |
|---|---|---|---|---|---|---|---|
| 1 | Verse | {line with ___} | {answer} / {wrong} / {wrong} | **{answer}** | {point} | {attack} (`{attack_id}`) | 🤡 {counter} (`{attack_id}_slapstick`) |
| 7 | Bridge | {line with ___} | {answer} / {wrong} / {wrong} | **{answer}** | {point} | {attack} (`{attack_id}`) | 🩸 {counter} (`{attack_id}_gory`) |

- **Phase** is exactly `Verse`, `Chorus`, `Bridge` or `Final`.
- **Line** may be shortened, but it must be the start of the §1 line.
- **Options** are separated by ` / `, with the answer among them.
- Ids are snake_case. Verse and chorus counters lean 🤡 slapstick; bridge and final chorus lean 🩸 gory. The last counter is the biggest payoff.

### Distractor notes
- **#1** {why each wrong option is plausible but wrong}
- …

---

## 5. Secret Cards in This Fight

Lost cards never change the lyrics. For each card the boss knows, one blank gets a 4th option and a nastier attack. Taunts play **only on a survival win**.

| Card | Loaded blank | Extra option | Aftermath taunt |
|---|---|---|---|
| {icon} {card name, as in the Act's card list} | #{n} ({answer}) | {extra option} | "{taunt}" |

Cards with no fight effect: {list}.

---

## 6. Fight Outcomes

### How a blank plays (shared rules ✅)
- The song pauses just before the blank word. The attack creeps for 5 s, and 3 options appear (4 if loaded).
- A cross-out costs 1 👀 and removes one wrong option, once per blank.
- **Right:** the word is sung and the counter plays.
- **Wrong or timeout:** the word is skipped, 보람 screams (§8), and she loses 1 heart. No dodges.

### 🏆 Revenge win — no hearts lost during the fight
*(Hearts restored to 5.)* {the boss's brutal death, caused by their own sloppy mistake}

### 😐 Survival win — hearts lost, at least ½ heart left
*(No restore. Both survive.)* {how the boss is quelled}, with the boss's line in double quotes: "{survival line}"

### 💀 Game over — 0 hearts
The news anchor 문태식, in a flat tone:
> *"{game-over headline}"*

다시 부른다 restarts the song from the top with the hearts and 👀 from the fight's start.

### After the last blank (shared rule ✅)
The score screen appears after the last sung line. The rest of the track plays underneath it.

---

## 7. Track and Timing  (fill in after Suno)

| Item | Value |
|---|---|
| Game track | `audio/songs/{song}_{singer}.mp3` (ASCII filename) · {length} |
| Timing source | `data/songs/{song}_{singer}.labels.txt`. Blank times live **only** here |
| Timed with | `--mark-song {boss}` ☐ |
| Checked with | `--check-song {boss}` ☐ |
| As-sung check | Sung words match §1 ☐ · Differences: {list, or none} |

**Labels file:** Audacity format, one label per line: `start<TAB>end<TAB>text`, in the order of the song.
- `(intro) …` and `(outro) …`: the spoken parts. Timing only, hidden in the game.
- `(skip) …`: anything else Suno added. Hidden.
- `[n] {word}`: blank word n.
- Every other label is a lyric fragment. In order, the fragments must spell the §1 lines (only Hangul is compared).
- Rough times are fine. `--mark-song` sets the blank times exactly.

**Steps**
1. Write the labels file. A rough pass in Audacity is enough.
2. Run `--mark-song {boss}`: tap Space with the 8 clicks, then hold Space while each blank word is sung. Enter keeps, R redoes. It saves and rebuilds the song file itself.
3. Run `--check-song {boss}` to listen to the fight with no damage. N / B jump between blanks.

---

## 8. Sound Effects

| Sound | Files | Use |
|---|---|---|
| 보람's scream (shared) | `audio/sfx/scream1–3.mp3` | Every wrong answer or timeout; random, never twice in a row |
| {song-specific sound, if any} | {file} | {when} |

---

## 9. Take Log

| Take | Date | Singer / voice | Notes | Selected |
|---|---|---|---|---|
| 1 | {date} | {…} | {…} | ☐ |

---

## 10. Open Items

1. {question or task}
