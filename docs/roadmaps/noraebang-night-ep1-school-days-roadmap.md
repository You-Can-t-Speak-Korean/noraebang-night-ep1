# Noraebang Night — Episode 1: 학교 시절 (School Days)
## Master Roadmap

*Version 0.1 · Drafted 20 October 2026*
*Parent document: Noraebang Night — Master Roadmap*
*Brand: <니가 한국어 못해>*

> **How to read this document**
> - ✅ **DECIDED** — locked in.
> - 🟡 **SUGGESTED** — surplus ideas. Bosses, scenes, songs and details are **cut and finalized in session**.
> - ❓ **OPEN** — needs a decision.
> - 🔍 **VERIFY** — historical or factual detail to confirm during research.
>
> This roadmap deliberately contains **more ideas than the game needs**. Cutting happens in session.

---

## 0. Decision Log

| # | Decision | Status |
|---|---|---|
| 1 | Episode 1 covers her school years, 1979–1991, in three Acts | ✅ |
| 2 | **Each Act is its own standalone game and release** | ✅ |
| 3 | The three Acts are later packaged together as **학교 시절** | ✅ |
| 4 | Act titles: **국민학교 시대 · 중학교 시대 · 고등학교 시대** | ✅ |
| 5 | Each boss gets **one or two dialogue scenes** leading into its noraebang boss fight | ✅ |
| 6 | Pre-1991 fights take place in **proto-noraebang arenas** | ✅ |
| 7 | The **first-ever noraebang** in Korea is the arena for the Episode's final boss fight | ✅ |
| 8 | Protagonist: **장보람** | ✅ |
| 9 | Opening: animated assassination of 박뻥희 while singing with 진두통 → blood-smear title → classroom TV | ✅ |
| 10 | Nobody in the classroom cares about the assassination | ✅ |
| 11 | Wacky, over-the-top violence in noraebang fights only; **no sexual content of any kind** | ✅ |
| 12 | Free release; donations accepted (including crypto) | ✅ |
| 13 | Code: AGPL-3.0 or equivalent. Art, music, songs and script: **all rights reserved** | ✅ |
| 14 | Distribution: own website (Salad Fingers model) | ✅ |
| 15 | Length: build it and find out | ✅ |
| 16 | Engine | 🟡 Godot |

---

## 1. Episode Vision

### Pitch
장보람, a Korean-Ethiopian girl born in 1972, survives twelve years of Korean schooling under a military government, a democracy movement and an Olympic boom — where the most dangerous thing in the room is always another person with a microphone.

### Episode pillars
1. **Childhood is not innocent.** The satire treats school as the first hierarchy, not a nostalgic one.
2. **The adults' history happens in the background.** Assassinations, coups, protests and Olympics play on TVs and radios while the kids fight over 도시락 and status.
3. **She learns the rules before she can break them.** Language progresses from kids' 반말 to exam-grade institutional Korean.
4. **The noraebang is coming.** Every Act's arenas are stand-ins for a thing that doesn't exist yet — until the finale.

### Structure

| Act / Release | Years | Age | School | Arena theme |
|---|---|---|---|---|
| **국민학교 시대** | 1979–1985 | 7–13 | 국민학교 | Parties, 학예회 stages, 반주기 |
| **중학교 시대** | 1985–1988 | 13–16 | 중학교 | 롤러장, 오락실, church, tour buses |
| **고등학교 시대** | 1988–1991 | 16–19 | 고등학교 | 음악다방, 독서실, the first noraebang |

> Note: it was called **국민학교** throughout her school years; the name changed to 초등학교 in 1996 🔍.

### Per-boss loop ✅
```
Dialogue scene 1  →  (optional) Dialogue scene 2  →  Noraebang boss fight  →  Aftermath beat
   눈치, privacy        escalation, the boss            song + attacks +        consequences carry
   meter in play        reveals their agenda            lyric counters          into the next boss
```

---

## 2. Opening Sequence ✅

**Shot list (draft)**
1. **Night, 1979.** A private dinner. President **박뻥희** sings a duet with the singer **진두통** — her hit song **〈그 새우, 그 짜장〉**.
2. Mid-chorus, 박뻥희's head is blown off.
3. Blood smears across and off the screen, revealing the title: **노래방 나이트: 국민학교 시대**.
4. **Hard cut** to a classroom TV showing the news.
5. 장보람 walks into the classroom.
6. Nobody gives a damn. Kids trade stickers, the 반장 takes names, the teacher reads the attendance roll over the news anchor.
7. First dialogue choice of the game.

**Notes**
- No one cries. The indifference *is* the joke.
- 〈그 새우, 그 짜장〉 needs a full original song (Act 1 music deliverable #1). A fragment can recur through the Episode — on radios, hummed by adults, as a ringtone-before-ringtones gag.
- 🟡 진두통 can come up in later classroom dialogue: kids gossiping about whether she'll ever sing again; a 담임 who is a secret fan; a 학예회 kid who performs 〈그 새우, 그 짜장〉 and gets punished for it.
- 🔍 Timing: the assassination took place on 26 October 1979; 보람 entered 국민학교 in March 1979, so this is her first year. Classroom scene happens the next morning.

---

## 3. Characters

### 3.1 장보람 ✅
- Born 1972. Korean mother, Ethiopian father.
- Name: 순우리말 보람 ("worthwhile result, the fruit of effort"). 🟡 Bosses and classmates can mangle, mock or misread it.
- Goal in every scene: survive without giving up private information or compromising herself.

### 3.2 Family 🟡 (decide in session)
| Character | Suggestions |
|---|---|
| **Father** | Kagnew Battalion veteran of the Korean War 🔍. Quiet, proud, the target of every intrusive question. Possible home-only Amharic phrases. |
| **Mother** | Options: 시장 vendor, 다방 owner, nurse. Fiercely practical; teaches 보람 how to deflect. |
| **Grandmother (외할머니)** | Possible. Either an ally or the family member who never accepted the marriage. |

### 3.3 Recurring characters across all three Acts 🟡
| Character | Role |
|---|---|
| **The Rich Classmate** | First boss in Act 1; returns in Act 2 as a social queen; possibly Act 3's exam rival. A three-Act nemesis. |
| **Best friend** | Ally, information broker, sometimes a liability. Their mother is the Judgmental Mother boss. |
| **The 반장** | Grows from a 국민학교 tattletale into a 선도부 enforcer and later a model student who reports everyone. |
| **The news anchor** | Recurring TV presence narrating national events nobody in the room cares about. |

---

## 4. Act 1 — 국민학교 시대 (1979–1985, age 7–13)

### Language focus
- Kids' 반말 among classmates
- Basic 존댓말 to adults — and getting it wrong in punishable ways
- 호칭: 선생님, 아줌마, 아저씨, 언니/누나, 형/오빠
- 의성어·의태어 (sound and motion words — ideal for kids' songs and attacks)
- School-institution language: 애국조회, 주번, 반장, 조회, 종례
- 🔍 Early-80s children's slang (research list)

### Period details bank 🔍
- **국기에 대한 맹세** and **국민교육헌장** recitation
- **애국조회** on Monday mornings
- **반공 education**: poster contests, essay contests, 반공 speeches
- **도시락 inspection** (mixed-grain checks)
- 주번 duty, 청소 시간, 우유 급식
- **Color TV broadcasting** arrives (1980) — status symbol
- **Curfew** lifted (1982)
- **프로야구** launches (1982) — kids' team jackets as status markers (use parody team names)
- **Uniform and hairstyle deregulation** (early 80s)
- **Private tutoring ban** (1980)
- 문방구, 불량식품, 딱지, 구슬, 종이인형

### Arenas (proto-noraebang) 🟡
- The Rich Classmate's **birthday party** with a home **반주기**
- **학예회** stage
- **어린이날** event stage
- A relative's **환갑잔치** with a hired 반주기 and microphone
- **소풍** 장기자랑 in the park
- **Classroom** with the TV used as a karaoke screen in a dream-logic sequence

### Boss roster (surplus) 🟡

| # | Boss | Concept | Dialogue scenes | Arena | Song genre |
|---|---|---|---|---|---|
| 1 | **The Rich Classmate** ✅ (first) | Jealous, spiteful, owns a color TV and a 반주기 | First day: "너 어디서 왔어?"; birthday invitation that's actually a trap | Her birthday party | Bright 80s 동요-pop |
| 2 | **반장** | Takes names, reports everyone, loves rules | 반장 election; 주번 duty | 학예회 stage | March / 군가 parody |
| 3 | **The Judgmental Mother** ✅ | Best friend's mother. Interrogates over fruit | Visit to friend's home; "아빠는 뭐 하셔?" | Living room with 반주기 | Old 가요 ballad |
| 4 | **담임 with a 몽둥이** | Discipline as performance art | 도시락 inspection; 숙제 검사 | Classroom | Trot |
| 5 | **교장선생님** | Endless 애국조회 speeches | Monday 애국조회 | 운동장 podium | Patriotic anthem parody |
| 6 | **문방구 아저씨** | Sells sugar, debt and 불량식품 to children | Buying 딱지 on credit | Back of the 문방구 | 뽕짝 |
| 7 | **반공 Contest Judge** | Grades children's anti-communist paranoia | Poster and essay contest | Contest stage | Military march |
| 8 | **Relative at the 환갑잔치** | Drunk uncle with opinions about her father | 환갑 party | Banquet hall with hired band | Trot medley |

### Act 1 final boss ❓
Options: the **담임** (discipline peak), the **교장선생님** (institution peak), or a **graduation-day** fight with the Rich Classmate.

### Act 1 attack ideas 🟡
Flicked boogers to the eye ✅ · poisoned drink ✅ (불량식품 juice) · cigarette-butt burns ✅ · broken-cord electrocution ✅ · mic beating ✅ · thrown chalk · 출석부 smack · 실내화 projectiles · 압정 on the chair · 지우개 dust blinding · 김치 국물 from a cracked 도시락 · 딱밤 barrage · 엎드려뻗쳐 freeze attack · 반공 poster spear · color-TV crush

---

## 5. Act 2 — 중학교 시대 (1985–1988, age 13–16)

### Language focus
- Peer hierarchy and 선배/후배 among teenagers
- Mid-80s teen slang 🔍
- Church and religious vocabulary
- Rumour, gossip and reputation language
- Insults, comebacks and 눈치 under social pressure
- Political vocabulary leaking in from the background (시위, 최루탄, 직선제)

### Period details bank 🔍
- 1986 **Asian Games** in Seoul
- **1987 democracy protests** — tear gas drifting past the school gates; teachers telling kids not to look
- 1987 constitutional change to direct presidential elections
- **Olympic preparation fever**: clean-up campaigns, etiquette campaigns, "foreigners are watching" messaging — aimed directly at 보람
- 롤러장, 오락실, 만화방, 빵집 dates
- 워크맨-style cassette players as status symbols
- 수학여행 tour buses

### Arenas 🟡
- **롤러장** DJ booth
- **오락실** — a cabinet's microphone mod
- **Church** 문학의 밤 / youth singing night
- **수학여행 tour bus** with the bus's karaoke system
- **만화방** back room

### Boss roster (surplus) 🟡

| # | Boss | Concept | Dialogue scenes | Arena | Song genre |
|---|---|---|---|---|---|
| 1 | **동아리 회장** ✅ | Runs the club like a dictatorship | Club recruitment; loyalty test | Club room / 학예회 | Folk guitar |
| 2 | **선도부 Enforcer** | Student discipline squad, armband, clipboard | Gate inspection; uniform and hair check | School gate at dawn | Military march |
| 3 | **학생주임** | Hunts troublemakers and "foreign influences" | Called to the office | Teachers' room | Trot |
| 4 | **The 짱** | Rules the school through fear | Lunch money; a bathroom summons | 오락실 | Early 80s rock |
| 5 | **롤러장 DJ** | Controls the music, controls the crowd | Couple-skate humiliation | 롤러장 | Disco / dance |
| 6 | **전도사** | Wants her soul, her family and her attendance | Church invitation | Church youth night | Gospel / CCM |
| 7 | **Olympic Etiquette Instructor** | Teaches kids to perform Korea for foreigners | Campaign assembly: "외국인 앞에서는…" | 운동장 stage | Olympic anthem parody |
| 8 | **The Rich Classmate (returning)** | Now the social queen | 수학여행 seating chart | Tour bus | Teen pop |

### Act 2 final boss ❓
Options: **학생주임**, **선도부 Enforcer**, or the **Olympic Etiquette Instructor**.

### Act 2 attack ideas 🟡
Roller-skate charge · 오락실 joystick whip · tear-gas canister lob · hymn-book slam · 선도부 armband choke · cassette-tape strangle · disco-ball crush · 수학여행 tour-bus brake slam · bleach-blonde ruler check

---

## 6. Act 3 — 고등학교 시대 (1988–1991, age 16–19)

### Language focus
- Exam vocabulary and 한자어
- Introductory **사자성어**
- Formal institutional 존댓말 (teachers, 원장님, officials)
- Late-80s / early-90s slang 🔍
- Persuasion, bargaining and deflection with adults

### Period details bank 🔍
- **1988 Seoul Olympics**
- **교련** (military drill) as a school subject
- **학력고사** era of university entrance exams
- **독서실** culture, all-night studying
- Restrictions on private tutoring and 학원 for students — **the 학원 원장님 runs an illegal underground 학원**
- 1989 teachers' union movement and teacher dismissals
- Early 1991: the **first noraebang** opens in Korea

### Arenas 🟡
- **음악다방** DJ booth
- **독서실** at 3am
- **교련** parade ground
- **Olympic** street celebration stage
- **The first noraebang** ✅ (Episode finale)

### Boss roster (surplus) 🟡

| # | Boss | Concept | Dialogue scenes | Arena | Song genre |
|---|---|---|---|---|---|
| 1 | **교련 Teacher** | Turns PE into boot camp | Drill inspection | Parade ground | 군가 |
| 2 | **The Exam Rival** | Top-of-class rival — possibly the Rich Classmate | Mock-exam rankings posted | 독서실 | Late-80s ballad |
| 3 | **음악다방 DJ** | Gatekeeps cool, judges everyone's taste | Requesting a song | 음악다방 | Folk / 통기타 |
| 4 | **독서실 총무** | Rules the study room like a prison warden | Seat assignment; noise complaint | 독서실 | Trot |
| 5 | **Illegal 과외 Tutor** | Sells answers, sells fear | Secret lesson in an apartment | Apartment living room | Ballad |
| 6 | **Olympic Volunteer Coordinator** | Wants her as a "global" face — on his terms | Recruitment for the Olympics | Street celebration | Olympic anthem parody |
| 7 | **학년주임** | Controls university recommendations | Career counselling | Office | Trot |
| 8 | **학원 원장님** ✅ (Episode final boss) | Runs an illegal underground 학원; sells parents fear, sells kids misery | Enrollment interview; exposure of the 학원 | **The first noraebang** | Final boss medley |

### Episode finale ✅
The last fight of 학교 시절 takes place in **the first noraebang in Korea**, early 1991.

❓ **OPEN — How does the 원장님 get her there?** Options:
- (a) A graduation "celebration" — the 원장님 takes top students to a brand-new noraebang to recruit them for 재수 or brag to parents.
- (b) 보람 fails or skips the 학력고사, enters the 원장님's **재수** 학원, and the fight happens before she starts university (would shift University to 1992).
- (c) The 원장님 is an investor in the first noraebang.

🔍 Location and date: the first noraebang is commonly attributed to **Busan, 1991**. A Busan trip for the finale may be needed — or fictionalize the location.

### Act 3 attack ideas 🟡
Rifle-butt drill strike (교련) · 문제집 avalanche · 학력고사 OMR-card paper cuts · 독서실 lamp electrocution · hot 컵라면 splash · coffee-from-a-vending-machine scald · tuition-bill strangle · microphone-cord whip (first real noraebang mic) · tambourine bludgeon

---

## 7. Songs & Music

### Principles ✅
- All songs original. Public-domain 민요 may be used directly.
- No licensed commercial songs.
- All rights reserved.

### Episode song list (draft) 🟡
| # | Song | Use | Genre |
|---|---|---|---|
| 1 | **〈그 새우, 그 짜장〉** ✅ — 진두통 | Opening assassination; recurring motif | Late-70s 가요 ballad |
| 2 | One song per boss (8 per Act, surplus) | Boss fights | See boss tables |
| 3 | Act title themes ×3 | Menus and title cards | Era-specific |
| 4 | Finale medley | 학원 원장님 fight | Mashup of the Episode's motifs |

### Song design requirements
- Lyrics written to the Act's language focus.
- Each song marks which lines are **fill-in-the-blank** and what each blank teaches.
- Wrong answers must be *plausible* — the distractors teach as much as the answers.
- Each boss phase (verse → chorus → bridge → final chorus) gets harder blanks.

---

## 8. Systems in Episode 1

| System | Episode 1 role |
|---|---|
| **Dialogue & 눈치** | Introduced in Act 1 with simple 반말/존댓말 choices; deepens through Acts 2–3 |
| **Privacy & Integrity meter** | Debuts in the first scene. Carries across all three Acts, and later into University |
| **Noraebang fights** | Fill-in-the-blank lyrics counter attacks; boss phases escalate per song section |
| **Era layer** | 1979–1991: TV news, prices, fashion, smoke-filled rooms |
| **Era slang codex** | Collects expressions from the 1980s and early 1990s |
| **Save carry-over** | ❓ Does each Act import a save from the previous Act? |

---

## 9. Production Plan

### Release order ✅
1. **국민학교 시대** — standalone release
2. **중학교 시대** — standalone release
3. **고등학교 시대** — standalone release
4. **학교 시절** — packaged bundle of all three

### Per-Act milestones 🟡
| Milestone | Contents |
|---|---|
| Pre-production | Final boss list, dialogue scene outlines, song list, language curriculum, art style |
| Vertical slice (Act 1 only) | Opening sequence + Rich Classmate dialogue scene + Rich Classmate boss fight |
| Alpha | All dialogue scenes and fights playable with placeholder art and music |
| Beta | Final art, final songs, balancing, Korean proofreading |
| Release | Website launch, donation page, trailer |

### Act 1 vertical slice ✅ (target)
1. The 박뻥희 / 진두통 opening and blood-smear title.
2. The classroom scene where nobody cares.
3. Rich Classmate dialogue scene (first intrusive questions, privacy meter).
4. Rich Classmate noraebang fight at her birthday party with one complete original song.
5. Win and loss states.

---

## 10. Licensing, Distribution & Brand

### Licensing ✅
- **Code:** AGPL-3.0 (❓ or GPL-3.0 as the equivalent — the AGPL's network clause matters little for an offline game).
- **Art, music, songs, script, characters:** all rights reserved.
- Separate `LICENSE` files for code and assets; a clear README stating which is which.
- ❓ Contributor agreement if outside developers submit code.

### Distribution ✅
- Free download from the team's **own website**.
- Donations: card, crypto and others.
- ❓ Optional mirrors (itch.io, GitHub Releases) to handle download bandwidth.
- 🔍 Check Korean tax and reporting rules for donation and crypto income.

### Brand ✅
- Studio / brand name: **<니가 한국어 못해>**.
- 🟡 The website becomes the brand hub: Noraebang Night, Hangul Hiking Trip and future Korean-education projects.

### Pre-release checks 🟡
- Legal review of satirical names (박뻥희, 진두통, parody teams and companies).
- Content warning screen — informs, doesn't apologize.
- Native-speaker review of all Korean for period accuracy.

---

## 11. Session Agenda

1. Final boss roster for each Act (cut from the surplus)
2. Final boss for Acts 1 and 2
3. How the 학원 원장님 gets 보람 into the first noraebang (§6)
4. 보람's family: father's backstory, mother's occupation, grandmother
5. The best friend: name and personality
6. Recurring Rich Classmate: name and three-Act arc
7. Save carry-over between standalone Acts
8. Song production: who writes and performs
9. AGPL-3.0 vs GPL-3.0; contributor agreement
10. Website, donation setup and mirrors

---

## 12. Research Checklist 🔍

- [ ] 26 October 1979 details for the opening's satirical framing
- [ ] 국민학교 → 초등학교 rename date (1996)
- [ ] 1980 private-tutoring ban and when student 학원 attendance was re-allowed
- [ ] Color TV broadcast start (1980); curfew lifted (1982); 프로야구 launch (1982)
- [ ] Uniform and hairstyle deregulation dates, and the uniform's return
- [ ] 도시락 mixed-grain inspection — still active in 1979–80?
- [ ] 교련 curriculum in late-80s high schools
- [ ] 학력고사 years and format
- [ ] First noraebang in Korea: location and date
- [ ] Kagnew Battalion service dates and veterans who stayed in Korea
- [ ] Slang lists: early 80s, mid 80s, late 80s, early 90s
- [ ] Prices: 불량식품, 오락실 coins, 롤러장 entry, 음악다방 coffee
- [ ] 반주기 and karaoke equipment available in 1980s Korea
