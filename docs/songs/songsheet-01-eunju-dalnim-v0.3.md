# Song Sheet 01 — 〈달님은 계란 후라이〉

*v0.3 · 7 November 2026 · Supersedes v0.2 (21 October 2026)*
*Act 1: 국민학교 시대 · Boss 1: 김은주 · Vertical slice*

> Production document. Changes are made by issuing a new version; v0.2 stays unchanged.
> This sheet describes the song **as built and played** (Build Step 4, Noraebang Night Ep1 Project Log 006).
> Native-speaker review passed ✅: every line, option and taunt, checked several times.
> ✅ decided · 🟡 proposed · ❓ open · 🔍 verify

### What changed since v0.2
| § | Change |
|---|---|
| 1, 2 | **보람 sings** the game track. 은주 picks the song and speaks the intro. The spoken outro is 보람's |
| 3 | Attack and counter ids added (as used in the game) |
| 4 | Loaded blanks built and approved. Taunts play only on a survival win |
| 5 | Win rules updated: revenge = no hearts lost; survival = hearts lost, at least ½ heart left. **No dodges** |
| 5 | How a blank plays: the song pauses just before the blank word; a wrong answer skips the word and screams |
| 6 | Music made with **Suno Pro** (replaces the Riffusion notes) |
| 7 | New: track and timing (labels file, `--mark-song`) |
| 8 | New: sound effects (three screams) |
| 9 | Open items updated; native review and line [5] closed |

---

## 1. Overview

| Field | Value |
|---|---|
| Boss | 김은주 |
| Arena | 은주's birthday party, 1979. Living room, home **반주기**, a color TV showing black-and-white, a 장식장 full of her father's 양주 |
| Singer | **보람 sings** ✅. 은주 picks the song and orders 보람 to sing it; she speaks the intro. Lyrics scroll on the 반주기 screen; the player fills the blanks |
| Topic category | **Space & Fantasy** — the moon is a fried egg |
| Resonance | Loose: a spoiled birthday girl who wants to eat the whole sky |
| Genre | Bright late-70s / early-80s 동요-pop. Cute, then cracked, then hungry |
| Tempo / key | ~120 BPM, major key; bridge drops to half-time and detunes |
| Register | 해요체 throughout — the classic 동요 register |
| Language focus | Colours, kitchen nouns, 의성어, 누가, 있다/없다, past tense, adjectives, -고 싶다, -(으)면 |

### Song arc
| Phase | What happens in the song | What happens in the room |
|---|---|---|
| 1 Verse | The moon is a fried egg in a frying-pan sky | Party tricks turn nasty |
| 2 Chorus | Stars are salt; someone eats the moon every night | Escalation |
| 3 Bridge | The yolk bursts; the sky goes dark | Blackout — the rules break *(lighting effects are off until the art exists)* |
| 4 Final chorus | The singer wants to eat the moon | Signature carnage |

---

## 2. Full Lyrics

`⟦ ⟧` = blank (answer shown) · `[n]` = blank number

```
〈달님은 계란 후라이〉

[Intro — spoken over the 반주기 jingle]
은주: 자, 다 조용히 해! 내 노래야!

[Phase 1 — Verse]
밤하늘을 보세요, 동그란 게 떴어요
하얀 흰자 가운데 ⟦노란⟧ 노른자                    [1]
엄마는 달님이래요, 선생님도 달님이래요
아니에요, 아니에요, 그건 계란 후라이예요
하늘은 커다란 ⟦프라이팬⟧                          [2]
기름이 ⟦지글지글⟧, 별들이 톡톡 튀어요              [3]

[Phase 2 — Chorus]
달님은 계란 후라이, 계란 후라이
별은 하얀 ⟦소금⟧이에요, 솔솔 뿌려요               [4]
달님은 계란 후라이, 계란 후라이
밤마다 ⟦누가⟧ 달을 먹어요?                        [5]
아침이 되면 하늘에 달이 ⟦없어요⟧                  [6]

[Phase 3 — Bridge — half-time, detuned, lights flicker]
어젯밤에 나는 ⟦봤어요⟧                            [7]
하늘에서 노른자가 톡 터졌어요
노란 비가 주룩주룩, 지붕 위에 뚝뚝
이제 하늘이 ⟦깜깜해요⟧                            [8]
(the lights go out)

[Phase 4 — Final chorus — frantic, louder]
달님은 계란 후라이, 계란 후라이
배가 고파요, 나는 달을 ⟦먹고 싶어요⟧               [9]
달님은 계란 후라이, 계란 후라이
달이 다시 ⟦뜨면⟧ 한 입에 꿀꺽!                     [10]

[Outro — spoken, sweetly]
보람: 잘 먹겠습니다.
```

- **Line [5]** ("밤마다 누가 **달을** 먹어요?"): the v0.2 edit is ✅ kept; the track sings it.
- **The track differs from the sheet in three places** (all ✅ kept as they are):
  - the spoken intro is 「다 조용히 해. 내 노래야.」, without 「자,」;
  - the intro is spoken in the track's single voice, not a separate 은주 voice. This may be revisited later, or left as is;
  - "(the lights go out)" is sung by Suno. It is hidden on the 반주기 screen.
- **Intro and outro** are in the audio and are **not shown** on the 반주기 screen ✅.

---

## 3. Blank Table

| # | Phase | Line | Options | Answer | Teaches | Attack (wrong) | Counter (right) |
|---|---|---|---|---|---|---|---|
| 1 | Verse | 하얀 흰자 가운데 ___ 노른자 | 노란 / 파란 / 까만 | **노란** | Colour adjectives | Booger flick to the eye ✅ (`booger_flick`) | 🤡 The booger ricochets onto 은주's party plate; she eats it without noticing (`booger_flick_slapstick`) |
| 2 | Verse | 하늘은 커다란 ___ | 프라이팬 / 냉장고 / 숟가락 | **프라이팬** | Kitchen nouns | Shaken 사이다 bottle fired as a glass rocket (`soda_bottle_rocket`) | 🤡 A frying pan drops from the sky; 보람 bats the bottle back and it corks 은주's mouth (`soda_bottle_rocket_slapstick`) |
| 3 | Verse | 기름이 ___, 별들이 톡톡 튀어요 | 지글지글 / 멍멍 / 엉엉 | **지글지글** | 의성어 | Birthday candles + hairspray flamethrower (`candle_hairspray_flame`) | 🤡 The flame U-turns; 은주's 앞머리 sizzles into a crispy fringe (`candle_hairspray_flame_slapstick`) |
| 4 | Chorus | 별은 하얀 ___이에요 | 소금 / 고추장 / 김치 | **소금** | Colour clue → noun | Party poppers packed with thumbtacks (`thumbtack_party_popper`) | 🤡 Tacks sprinkle back like salt; 은주 becomes a pincushion unicorn (`thumbtack_party_popper_slapstick`) |
| 5 | Chorus | 밤마다 ___ 달을 먹어요? | 누가 / 누구를 / 언제 | **누가** | 누가 (subject) | Cake knife throw (`cake_knife_throw`) | 🤡 The knife pins 은주's hair ribbon to the wall; she dangles, still singing (`cake_knife_throw_slapstick`) |
| 6 | Chorus | 아침이 되면 하늘에 달이 ___ | 없어요 / 있어요 / 많아요 | **없어요** | 있다 / 없다 | Party-hat cone driven into the eye (`party_hat_cone_stab`) | 🤡 The cone flips and lands on 은주's nose like a beak (`party_hat_cone_stab_slapstick`) |
| 7 | Bridge | 어젯밤에 나는 ___ | 봤어요 / 봐요 / 볼 거예요 | **봤어요** | Past tense -았/었- | 종이인형 paper-doll blade storm (`paper_doll_blade_storm`) | 🩸 The blades boomerang; 은주 gets paper cuts so deep she sprays like a lawn sprinkler (`paper_doll_blade_storm_gory`) |
| 8 | Bridge | 이제 하늘이 ___ | 깜깜해요 / 밝아요 / 따뜻해요 | **깜깜해요** | Adjectives | **Blackout:** 반주기 mic cord strangles, then electrocutes ✅ (`mic_cord_electrocution`) | 🩸 The current reverses; only sparks light 은주's pigtails standing up, smoking, her braces glowing (`mic_cord_electrocution_gory`) |
| 9 | Final | 배가 고파요, 나는 달을 ___ | 먹고 싶어요 / 먹었어요 / 먹지 마세요 | **먹고 싶어요** | -고 싶다 | Booger **sniper** ✅ (the flick, escalated) (`booger_sniper`) | 🩸 The round punches through 은주's 고깔 and bursts a 양주 bottle in the 장식장, which explodes over her (`booger_sniper_gory`) |
| 10 | Final | 달이 다시 ___ 한 입에 꿀꺽! | 뜨면 / 뜨지만 / 떴어 | **뜨면** | Condition -(으)면 | The family's color TV dropped from above (`color_tv_drop`) | 🩸 The TV bounces off the 반주기 and lands on 은주; sparks fry her "sunny side up" (`color_tv_drop_gory`) |

🤡 = slapstick counter · 🩸 = gory counter. In the game, attacks and counters are still placeholders (labels and a blood burst) until the art exists.

### Distractor notes
- **#1** 파란 / 까만: grammatical, but a yolk is yellow.
- **#2** 냉장고 / 숟가락: 커다란 fits, but the next line's 기름 and frying need a pan.
- **#3** 멍멍 (dog) / 엉엉 (crying): real 의성어, wrong sound for oil.
- **#4** 고추장 / 김치: the 하얀 clue rules out red foods.
- **#5** 누구를: doubles the object with 달을. 언제: clashes with 밤마다.
- **#6** 있어요 / 많아요: the song's logic is that the moon is eaten by morning.
- **#7** 봐요 / 볼 거예요: 어젯밤 requires past tense.
- **#8** 밝아요 / 따뜻해요: the yolk has burst; the sky is dark.
- **#9** 먹었어요: grammatical, but the singer is still hungry and plans to eat the moon when it rises again. 먹지 마세요: a -세요 command to herself. Native review passed ✅.
- **#10** 뜨지만: "rises, but" breaks the logic. 떴어: breaks the sentence.

---

## 4. Secret Cards in This Fight ✅

Songs stay songs: lost cards **do not add lyrics**.

- For each card 은주 knows, one blank becomes **loaded**: **4 options instead of 3**, and its attack lands with a nastier flourish.
- 은주's taunts play in the aftermath, **only on a survival win** ✅ (a dead 은주 can't taunt).
- 자존심 and 엄마 일 have no fight effect ✅.

| Card | Loaded blank | Extra option | Aftermath taunt |
|---|---|---|---|
| 🇪🇹 아빠 나라 | #4 (소금) | 설탕 | "너네 나라에도 계란 있어?" |
| 💰 엄마 월급 | #6 (없어요) | 적어요 | "너네 엄마 월급으로 케이크 살 수 있어?" |
| 🍶 아빠 주량 | #9 (먹고 싶어요) | 마시고 싶어요 | "너네 아빠는 달 말고 소주 먹지?" |

---

## 5. Fight Outcomes

### How a blank plays ✅
- At each blank, the song **pauses just before the blank word** and reality freezes. The attack creeps toward 보람 for **5 seconds**, and 3 options appear (4 on a loaded blank).
- **Cross-out:** 1 👀 removes one wrong option (the game picks it), at most once per blank. Cross-outs never break a revenge win.
- **Right answer:** the song resumes and the blank word is sung. The counter plays.
- **Wrong answer or timeout:** the song skips the blank word, 보람 screams (§8), and she loses **1 heart**. The attack lands.
- **No dodges** for now ✅ (they may return later as an option).

### 🏆 Revenge win — no hearts lost during the fight
*(Cross-outs allowed. Hearts are restored to 5.)*

Played as a full Mortal Kombat–style fatality ✅. The 반주기 plays the 100점 fanfare. 은주 lunges for the mic to claim the score, trips on her own cord, and face-plants into the cake. The candles ignite her hairspray. She staggers into the 장식장; the 양주 bottles rain down and go up like fireworks. The color TV topples last and lands on her with a crunch. On its cracked screen, the black-and-white news keeps playing. Through the window, the moon hangs perfectly round and yellow.

The guests keep eating cake.

### 😐 Survival win — hearts lost, at least ½ heart left
*(No restore. 은주 and 보람 both survive.)*

The 반주기 shorts out and the party ends early. 은주 sulks into the cake: "흥. 다음엔 안 불러." She never bullies 보람 again. She just pretends she doesn't exist.

### 💀 Game over — 0 hearts
The news anchor, in the same flat tone as the assassination:
> *"오늘 저녁, 국민학교 1학년 장보람 양이 생일 파티에서 사망했습니다. 다음 소식입니다."*

Back in the classroom, the kids trade 딱지. **다시 부른다** restarts the song from the top, with the hearts and 👀 she had when the fight started. Game over stops the music at once.

🟡 The headline names the attack that landed the final hit (e.g. "…컬러 TV에 깔려 사망했습니다"). Still to be written.

### After the last blank ✅
The score screen (점수: {n}점) appears after 「한 입에 꿀꺽!」. The spoken outro and the rest of the track play underneath it until the track ends.

---

## 6. Music Production ✅

**Tool:** Suno Pro.

**Styles, as pasted** (the v0.2 prompt):
```
Bright late-1970s Korean children's song, 동요 style, cheerful synth and toy piano, tinny home karaoke-machine sound, 120 BPM, major key, single young girl's voice. Bridge: half-time, detuned, eerie, music-box feel. Final chorus: frantic, faster, louder.
```

**Lyrics, as pasted:** §2 as written in Song Sheet 01 v0.2, the first sheet for this song, with the speaker names removed. Suno read the names aloud, so they had to go.

**Versions generated:** 보람 (the game track), 은주 and 현정. Only the 보람 version is used.

---

## 7. Track and Timing ✅

| Item | Value |
|---|---|
| Game track | `audio/songs/dalnim_boram.mp3` · 125.37 s as Godot reads it |
| Timing source | `data/songs/eunju_dalnim_boram.labels.txt` (Audacity label format). The blank times live **only** there and are not copied into this sheet |
| How blanks were timed | In the game with `--mark-song eunju`: calibrate, then hold Space while each blank word is sung |
| How to check | `--check-song eunju` (no damage; N/B jump between blanks) |
| Pause point | `pause_at` = blank word onset − 0.05 s |
| Hidden lines | Intro, outro and "(the lights go out)" are timed but not shown |
| Original hand transcription | `docs/backups/eunju_dalnim_boram.labels.txt`: kept untouched, not used by the game |

---

## 8. Sound Effects ✅

| Sound | Files | Use |
|---|---|---|
| 보람's scream | `audio/sfx/scream1.mp3` (short), `scream2.mp3` (long), `scream3.mp3` (mid) · made with Fish Audio | Plays on every wrong answer or timeout, over the music. One is picked at random, never the same one twice in a row |

---

## 9. Open Items

1. 🟡 Game-over headlines per attack (WRITE).
2. Attack, counter and revenge visuals: placeholders until the art exists.
3. Bridge and blackout lighting: effects are off until the art exists.
4. The intro voice (§2): accepted for now; may be revisited later or left as is.
