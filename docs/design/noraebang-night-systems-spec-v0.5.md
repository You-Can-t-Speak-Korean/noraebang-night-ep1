# Noraebang Night — Systems Spec

*Version 0.5 · 16 November 2026 · Supersedes v0.4 (25 October 2026)*
*Applies to: the whole game. Act 1 values given where they differ.*

> **Document rules**
> - Production document. Changes are made by issuing a **new version**; earlier versions stay unchanged.
> - What is actually built, and any deviation from this spec, is recorded in the **project logs**.
> - **DDEOK as a token** (supply, emission, NFTs, stores, staking, on-chain) is governed by the DDEOK documents. This spec covers only how DDEOK works inside Noraebang Night.
> - ✅ decided · 🟡 proposed default, adjust in session · ❓ open · 🔍 verify

### What changed since v0.4
v0.5 brings together the overrides recorded in Project Logs 004 §3, 005 §4, 006 §5 and Noraebang Night Ep1 Project Log 007 §4. It describes the game as built and played up to commit `f5dadce` (Build 6a–6b, 16 Nov 2026).

| § | Change | Source |
|---|---|---|
| 1 | New goal: **DDEOK has real value** without buying the game | Log 007 #7 |
| 2.1 | No overnight refill (confirmed). Health items are **carried** and used from the inventory or with **E** | Log 004 #3, Log 007 #16–18 |
| 2.2 | **No dodges** (for now). **No 눈치 → DDEOK overflow**: extra 눈치 at the cap is lost. **눈치 is non-commercial**. "Exactly 7 before the first fight" removed | Logs 006, 007 |
| 2.5 | DDEOK off-chain until ready; first on-chain run is a store test; no overflow earnings | Log 007 #6, #9 |
| 2.6 | **New: items and storage** (필통, 책가방, 공책) | Log 007 §4.3 |
| 3.2 | 3 lanes; Enter uses doors; no room titles; no names over characters | Log 005 #1–3, #16–17 |
| 3.3 | The per-map-day deal as built | Log 005 #8 |
| 3.5, 3.8 | The Boss 1 party as built (Map 02, Scene 03) | Log 007 §4.5 |
| 3.6 | **Dying at the party restarts the party**, not the game | Log 007 #29 |
| 3.7 | Map 01 as built | Log 005 |
| 4.5 | Full control list (Tab, E, X, Esc, F9) | Logs 005–007 |
| 4.6 | **The 문방구 as built**; no 눈치 for sale | Log 007 §4.4 |
| 5 | **보람 sings.** The song pauses before each blank word; a wrong answer skips the word and screams. New win rules. Results after the last sung line; the track plays out | Logs 006, 007 |
| 5.7, 6.4 | **Suno Pro.** One song sheet per song (Template v0.2). Song timing measured in the game with `--mark-song` | Log 006 |
| 6.7, 6.8, 7 | GameState, folders and saving as built (save v4, three checkpoints) | Logs 005–007 |
| 10 | Open questions updated | — |

---

## 1. Design Goals ✅

1. **Easy to understand.** Every number on screen is clear within the first scene.
2. **Easy to maintain.** The same rules run from 1979 to 2030. New scenes, maps, songs, items and shops are **data, not code**.
3. **The two halves feed each other.** Playing the social scenes well makes the fights easier.
4. **The long game matters.** What 보람 gives away follows her to the ending.
5. **Survival horror.** Risk everywhere, scarce healing, violence wherever it fits. Exploring makes players nervous and eager at the same time.
6. **PC first.** Keyboard and mouse. A phone version is a later project.
7. **DDEOK has real value.** It buys real power and ability in the game, but never a way to buy through it. 🆕

---

## 2. Resources ✅

All resources are **on screen in every part of the game**.

| Resource | Icon | Changes | What it does |
|---|---|---|---|
| **체력** (hearts) | ❤️ | Lost to traps, fights and other dangers; restored by health items and revenge wins | Survival. 0 = death |
| **눈치** | 👀 | Earned only by reading the room in dialogue; spent on cross-outs in fights | Makes fights easier |
| **비밀** (secret cards) | 🔒 | Lost in dialogue | Bosses use what she gives away; decides the ending |
| **DDEOK** | 🍡 (송편 icon) | Found while exploring | Buys items at the era's shop |
| **Items** 🆕 | — | Found, bought, or won | Storage, health items, notes (§2.6) |
| **점수** | 🎤 | End of each fight | Noraebang-machine score. Bragging only |

### 2.1 ❤️ 체력 — Hearts
- ✅ **Maximum 5 hearts** (10 halves). Shown on screen at all times.
- ✅ Lost in **halves or wholes**. Most traps cost **½**; a rare few cost **1**. A wrong answer in a fight costs **1**.
- ✅ **No automatic refill**, including **no overnight refill**. Damage from exploring carries into fights, and damage from fights carries out.
- ✅ **Restored by:**
  - **health items**: 반창고 (+½) and 빨간약 (+1), carried in storage and used from the inventory (Tab) or with quick heal (**E**), §2.6;
  - a **revenge win**, which restores hearts **to full (5)**.
- ✅ 0 hearts = **death** (§3.6 outside fights, §5.5 in fights).

### 2.2 👀 눈치
- ✅ **Earned only by reading the room** in dialogue, forced or optional: a good read = **+1 눈치**.
- ✅ **Non-commercial.** 눈치 is never sold, bought or traded for DDEOK, like real-life 눈치.
- ✅ **Spent** in fights on **cross-outs**: 1 눈치 removes one wrong option (the game picks which), **at most one per blank**.
- ✅ **No dodges** for now. ❓ They may return later as an optional feature.
- ✅ **Cap: 7.** 눈치 earned at the cap is **lost**. It does **not** convert to DDEOK (temporary decision, for tokenomics and cheat prevention).
- ✅ Act 1's forced scenes before Boss 1 offer **up to 8**: Scene 01 ×3, Scene 02 ×3, Scene 03 ×2. Optional conversations can add more, but anything over 7 is lost.
- 🟡 Tokens carry over between bosses within an Act.
- ✅ On a fight game over, 눈치 resets to its value at the fight's start.

### 2.3 🔒 비밀 — Secret Cards ✅
- 보람 holds a hand of **secret cards**: private facts and her dignity.
- **Lost** when she overshares or compromises herself in dialogue. **Cards never come back.** Losing a card already lost costs nothing more.
- A lost card becomes **known** by whoever is in the room (the scene's boss, or a named person).
- **Leak rule:** some people pass on what they hear. Act 1: **함현정 → 현정 엄마** (Boss 3).
- Known cards drive **taunts** in dialogue (§4.4) and **loaded blanks** in fights (§5.6).
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
- **점수 = 100 × correct answers ÷ total blanks**, rounded, shown as 「점수: {n}점」. 100점 gets the fanfare. 🟡 Low scores get era-appropriate insults.

### 2.5 🍡 DDEOK ✅
Governed by the DDEOK documents. Inside this game:
- DDEOK is shared by all NHMH games.
- **Off-chain until the game is ready.** The first on-chain run is a **test** of buying and selling in the Noraebang Night stores; real on-chain play comes only after that passes. On-chain and off-chain modes never mix.
- **Earned by finding it while exploring** (§3.3). 눈치 overflow no longer pays DDEOK.
- **Spent at** the era's shop (§4.6). All purchases go through one **store layer**, so an on-chain backend can replace the off-chain one without a redesign.
- **Real value:** DDEOK buys real advantages (storage, healing), kept scarce by small supply and limited stock.
- **Fair play:** DDEOK never buys answers, lyric blanks or a way past the Korean.
- **The client never decides what it earned** once on-chain. Off-chain mode keeps the same interfaces.
- ❓ **NFT scope.** 🟡 NFTs only for durable, tradeable items (clothes, storage, maybe skills); consumables, stats and notes stay in-game. To be decided in a DDEOK session.
- ❓ Bribes that change the story (listed in the DDEOK documents) are not designed for this game yet.

### 2.6 Items and Storage 🆕 ✅
- **Containers are items. 보람 starts with none.** Two equipment slots:
  - **Bag:** 필통 (4 slots); 책가방 (12 slots, not obtainable in Act 1). A 필통 can be carried inside a 책가방, taking 3 of its slots and keeping its own 4.
  - **Notebook:** 공책 (3 pages; one note per page). Notes live in the notebook. Later notebooks can hold more.
- Containers can be **upgraded or downgraded**. When a smaller container can't hold everything, the player chooses what to drop. ❓ What causes a downgrade is story, for later.
- **Health items** take one slot each. 🟡 `stack_max` = 1, ❓ maybe 3 after playtesting.
- **Picking up a health item:** it goes into a free slot. With no bag: 「넣을 데가 없다.」 [지금 쓴다] [버린다]. With a full bag: 「필통이 꽉 찼다.」 (the container's name), same choices.
- **Picking up a note:** its text shows first. With a notebook that has space: [공책에 넣는다] [버린다]. With none: 「공책이 없다.」 [버린다] [던져버린다]. Full: 「공책이 꽉 찼다.」 [버린다] [던져버린다].
- **버린다:** the item stays where it is and can be picked up again until 보람 leaves the map (the day changes) or dies. **던져버린다** (notes only) destroys the note for good.
- **Inventory:** **Tab**, outside fights and dialogue, once 보람 owns a bag or notebook. Actions: 쓴다 · 버린다 · 읽는다 · 던져버린다.
- **Quick heal:** **E**, anywhere including fights (the countdown keeps running), not during dialogue. Uses one health item in the order set by `quick_heal_order` (default **lowest first**: 반창고, then 빨간약). At full hearts: 「아픈 데가 없다.」.
- **Where storage comes from in Act 1:** the 문방구 (§4.6), and a **revenge win against 은주**, which gives a 필통 if 보람 has no bag.
- ❓ More container types, skills and clothes later.

---

## 3. Game Loop, Maps and Exploration

### 3.1 Loop ✅
```
Act
 └─ Boss loop (×4 in Act 1)
     ├─ Map: dialogue scene 1      → explore · talk · 👀 / 🔒 / 🍡 / ❤️ / items at stake
     ├─ Map: dialogue scene 2      → same
     ├─ Shop (when open)           → spend 🍡
     ├─ Pre-fight map (if needed)  → walk to the fight; its own checkpoint
     ├─ Noraebang fight (one room) → spend 👀 · lose ❤️ · 🎤 score
     └─ Aftermath beat             → outcome, taunts, rewards, year change
```

### 3.2 Maps ✅
- Every dialogue scene takes place in a **map**: side-on, connected rooms, a fixed camera per room following 보람 on X.
- **3 lanes** of depth (W/S). **Enter uses doors**; W/S are lanes only.
- Interaction ignores lanes. An **Enter keycap** shows above the nearest interactable only (never above 보람).
- The same map is reused across days, with characters in different places and different broadcasts on the TV.
- Forced dialogue starts when 보람 approaches the scripted character, or when the script says so. Movement is locked during dialogue.
- **Examinable objects** give a line of flavor and unlock an entry in the **era slang codex**. 🟡 Not built yet.
- **No room titles.** The final build uses natural signs (classroom plates etc.). **No names over characters** in the final build; dev labels only during development (F9).
- 🟡 Props aren't solid. ❓ Revisit with art.
- **Fights are not maps.** Every fight takes place in **one room**.

### 3.3 Exploration: hidden items and traps ✅
| Type | Examples | Effect |
|---|---|---|
| 🍡 **DDEOK** | — | Currency |
| 📜 **Secret notes** | A lyric scrap of the next song; the 반장's snitch list | Useful information; kept in the 공책 (§2.6) |
| ❤️ **Health items** | 반창고 (+½), 빨간약 (+1) | Carried in storage (§2.6) |
| 🪤 **Traps** | §3.7, §3.8 | −½ heart (most) or −1 (rare). Visible gore |

- **Random placement every load** from a per-map pool of candidate spots.
- **Anti-farming budget:** each map-day has a fixed set of items per save. Reloading reshuffles only where the uncollected items are. Collected items stay collected.
- **Per map-day deal (as built):** 2 DDEOK (1 each); 1 extra (note ×2 · 반창고 ×2 · 빨간약 ×1 weights); 2 traps, with ½-heart traps weighted 8:1 over 1-heart traps.
- **No markers.** Reading the room is the skill.
- Secret notes are best when they **teach**, and never give away answers (fair play).

### 3.4 Optional conversations ✅
- Classmates and others can be talked to freely. **Most are flavor**; 🟡 roughly **1 in 5 has stakes** (+1 눈치 or −1 card).
- **No markers.** Stakes pay out **once per save**.
- 🟡 After the first time, flavor conversations play a one-line repeat (to be written).

### 3.5 Pre-fight maps ✅
- Used **only when 보람 has to walk to the fight**. Short; ends at the fight trigger.
- **Each pre-fight map is a checkpoint** (§3.6). 🟡 Generalized from the Boss 1 party.
- **Boss 1: 은주's party** (Scene 03, Map 02), as built:
  1. Elevator → corridor → 은주 엄마 at the door (choice).
  2. The presents (choice).
  3. Roam: guests to talk to, finds and traps.
  4. The bathroom; walking back, 보람 overhears 은주 엄마 on the phone.
  5. The **장기자랑**: 「이제 장기자랑! 장보람, 너부터.」 … 「이 노래 몰라? 이 노래 모르는 애는… 죽어야 돼.」 The lights flicker; the fight starts.
- Every boss needs a believable trigger that leads into the song.

### 3.6 Death outside a fight ✅
- 0 hearts outside a fight → the **news-anchor game over** (문태식, flat tone).
- **Where she restarts depends on the map:**
  - **Map 01 (school):** the start of **Scene 01 (01-A)**, with **everything reset** (hearts, 눈치, cards, DDEOK, items, notes, shop stock).
  - **A pre-fight map (the party):** the **start of that map (03-A)**, with the state saved when the map began.
- Relaunching at a pre-fight map also restarts it from its start, so forced choices can't be farmed by quitting.

### 3.7 Map 01 — 국민학교 (1979) ✅ (as built)
- **13 rooms:** 교문 · 운동장 (철봉, 모래밭, 이순신 동상) · 현관 (신발장) · 1층 복도 (교무실, 1학년 3반, 화장실, 계단) · 2층 복도 · 빈 교실 · 골목길 · 전파사 · 문방구.
- 2층 locked on Saturday, open on Monday. Both shops hang off the 골목길.
- Saturday ends at the 교문 → 골목길 door; Monday ends at the **집** exit at the far right of the 골목길.
- The 문방구 opens after Scene 02's walk home (02-E). **Monday afternoon is the last chance to shop before Boss 1.**
- Candidate spots and traps per Spec v0.4 §3.7, plus **깨진 유리창** on the 2층 landing (1 heart). The 화장실 ghost is a plain 1-heart trap for now. The 전파사 뒤 spot is Monday-only.

| Scene | Day | Where |
|---|---|---|
| 01 | Sat 27 Oct, 쉬는 시간 | 1학년 3반; then the Saturday roam |
| 02 | Mon 29 Oct | 1학년 3반; the walk home with 현정; the Monday roam |
| 문방구 | Mon 29 Oct, after 02-E | 골목길 |

### 3.8 Map 02 — 은주네 아파트 (1979) 🆕 ✅
- **7 rooms:** elevator hall · corridor · 현관 · 거실 (장식장 with 양주, sofa, fridge, color TV, 반주기, cake) · 부엌 (telephone) · 복도 · 화장실.
- Scene 03, Saturday 3 Nov 1979, the day of the state funeral.
- Same deal as §3.3, about 8 spots. **Traps only at three spots:**

| Spot | Trap | Damage |
|---|---|---|
| 장식장 | A 양주 bottle falls | 1 |
| Sofa | A fork under the cushion | ½ |
| Fridge | The door slams on her fingers | ½ |

---

## 4. Dialogue Scenes

### 4.1 Flow ✅
1. Lines play with live 3D characters in the map; advance with **Enter**, **Space** or a click.
2. At a choice, **2–4 options**. Select with **W/S + Enter**, or click.
3. The choice resolves its one effect (§9.1) with a clear on-screen cue.
4. Movement is locked while dialogue is on screen.

### 4.2 Choice types ✅
| Type | Effect | Example |
|---|---|---|
| **Good read** | +1 👀 | 「우리 반에 은주는 세 명이나 있잖아.」 |
| **Overshare** | −1 🔒 (fact card) | 「우리 아빠는 소주 세 병 마셔!」 → 아빠 주량 |
| **Compromise** | −1 🔒 자존심 | 「서울에서 왔어요.」 (존댓말 to a classmate) |
| **Neutral** | none | 「너는?」 |
| **Dangerous** | −½ or −1 ❤️ | 🟡 Not used yet |

### 4.3 Timing
- ✅ **Act 1:** no timers on dialogue choices. 🟡 Later Acts: timed choices in high-pressure moments.

### 4.4 Conditional lines ✅
- Lines may play only when a card is **lost**, or **taunts** only when the speaker **knows** a card.
- Conditional lines never offer choices and never change state.

### 4.5 Movement and controls ✅
- **Camera:** side-on, *Little Nightmares*-style dollhouse view.

| Key | Action |
|---|---|
| **A / D** | Walk left / right |
| **W / S** | Change lane; up/down in menus and choices |
| **Enter** (or Space) | Talk, interact, search, doors, confirm |
| **Tab** | Inventory (outside fights and dialogue) |
| **E** | Quick heal (anywhere but dialogue) |
| **X** | Cross out a wrong option (in a fight's freeze) |
| **Esc** | Close a panel |
| **Mouse** | Click choices, buttons, inventory and shop rows, 눈치 eyes |
| **F9** | Dev labels on/off (development only) |

- 🟡 Controller later. Phone later, with an on-screen joystick.

### 4.6 The shop (Act 1: 문방구) ✅
- Each Act has a shop that fits its era. Shops are **data files**; a new shop needs only a new file.
- **Act 1 stock:**

| Item | Price (DDEOK) | Stock |
|---|---|---|
| 필통 | 3 | 1 |
| 공책 | 1 | 1 |
| 반창고 | 1 | 3 |
| 빨간약 | 2 | 2 |

- **No 눈치 for sale** (§2.2). ❓ Skills and clothes once they're defined.
- Stock is per save, **never restocks on reload**, and is restored by the death reset in Map 01.
- The shop checks **money, then space**. Health items need a free slot; containers equip, nest or upgrade.
- **Shopkeeper:** 고옥분, shown as 문방구 할머니. Lines: 어서 오세요. · 뭐 줄까? · 옜다. · 돈이 모자라네. · 그건 다 팔렸어. · 넣을 데가 없잖아. 필통부터 사 가. (bag full: first sentence only) · 또 와라.

---

## 5. Noraebang Fights

### 5.1 Structure ✅
- One original song per boss, in **four phases**:

| Phase | Section | Blanks | Blank difficulty | Attack intensity |
|---|---|---|---|---|
| 1 | Verse | 3 | Easiest | Nasty |
| 2 | Chorus | 3 | Easy | Worse |
| 3 | Bridge | 2 | Moderate | Rule-breaking |
| 4 | Final chorus | 2 | Hardest | Signature carnage |

- **10 blanks per song** in Act 1.
- ✅ **보람 sings** the game track. The **boss picks the song**, orders her to sing it, and may speak an intro.

### 5.2 A single blank: the freeze ✅
1. The song plays; the room moves; attacks wind up.
2. **Just before each blank word is sung**, the song pauses (at the word's onset − 0.05 s) and **reality freezes**. The attack **creeps toward 보람** for the countdown: **5 seconds** in Act 1 🟡.
3. The lyric line shows on the 반주기 screen with the blank and **3 options** (**4** on a loaded blank).
4. Before answering, the player may **cross out** one wrong option (1 눈치, once per blank) and may **quick heal** (E). The countdown keeps running.
5. **Right:** the song resumes and the blank word is sung. The counter plays.
6. **Wrong, or the countdown runs out:** the song **skips the blank word**; 보람 **screams** (one of three screams, at random, never the same twice in a row); she loses **1 heart**; the attack lands in gore.
- Hearts are the **global hearts** (§2.1).

### 5.3 Counters ✅
- Every attack has its own authored counter, **slapstick** or **gory**. Verse and chorus lean slapstick; bridge and final chorus lean gory. Every boss's last counter is the biggest payoff.

### 5.4 Winning ✅
| Win | Condition | Outcome |
|---|---|---|
| 🏆 **Revenge win** | **No hearts lost during the fight.** Cross-outs and healing don't break it | The boss dies a brutal, Mortal Kombat–style death caused by their own sloppy mistake. **Hearts restored to full (5).** Reward items per the data (Boss 1: a 필통 if 보람 has no bag) |
| 😐 **Survival win** | Hearts lost, **at least ½ heart left** | The boss is **quelled**; boss and 보람 both survive. No restore. The boss's **taunts play only here** |

### 5.5 Game over ✅
- The news anchor **문태식** reports 장보람's gruesome death in the same flat tone as the opening assassination.
- The music stops at once.
- **다시 부른다** restarts the fight from the top with the **hearts, 눈치, inventory and notes she had when the fight started**.
- 🟡 The headline names the attack that landed the final hit (to be written).

### 5.6 Known cards in fights ✅
- **Songs never change their lyrics** because of lost cards.
- **Loaded blank:** for each card the boss knows, one predefined blank gets **4 options instead of 3**, and its attack lands with a nastier flourish.

### 5.7 Songs ✅
- **Songs are songs.** Bosses never sing about their real lives. Strange, playful art pieces; original only.
- **Topic categories:** Food Love Songs · Animal Confessions · Weather Romance · Object Laments · Body Parts · Space & Fantasy · Numbers & Counting · Fake Jingles.
- The **boss** picks the song. 🟡 In certain later Acts the player picks from the 반주기 songbook.
- **Music tool: Suno Pro** ✅.
- **One song sheet per song**, written on **Song Sheet Template v0.2** ✅.

### 5.8 After the last blank ✅
- The results (점수, win type) appear after the **last sung line**.
- Then the aftermath (survival taunts, rewards) and, in the vertical slice, a summary and the end card.
- **The track plays to its real end underneath.** It stops only on a retry, when something else loads, or when the game quits. A game over stops it at once.
- **Lighting effects** (bridge flicker, blackout, final-chorus red) exist in the data but are **off until the art exists**.

---

## 6. Godot Pipeline

### 6.1 Engine, renderer, addons ✅
- **Godot 4.7.2**, **Forward+** (confirmed on the Intel Arc B580).
- **Live 3D** characters and rooms, side-on camera (Style Brief v0.3).
- **Dialogue Manager 4.1.0** (MIT). All licences compatible with AGPL-3.0 code.

### 6.2 Principle ✅
> **Scenes, maps, songs, items and shops are data. Code runs any of them.**
> Stage directions in `.dialogue` files call methods on the map or scene that plays them.
> Each new song still needs a small DEV step for the song builder's settings (song id, files, attack ids).

### 6.3 Dialogue files ✅
Dialogue Manager format, as in v0.4. Scripts in `docs/scripts/` are the source; the game's Korean is copied verbatim, and a test checks it against the script.

### 6.4 Song files and timing ✅
- **Song sheet** (`docs/songs/`, Template v0.2) → `tools/build_song.gd` → song JSON in `data/songs/`. The Song Sheet 01 build still reads v0.2 on purpose.
- **Timing source:** a labels file per track, `data/songs/{song}_{singer}.labels.txt`, in Audacity label format (`start<TAB>end<TAB>text`). Tags: `(intro)`, `(outro)`, `(skip)` (timed, hidden on screen) and `[n] word` (blank word n). Other labels are lyric fragments that must spell the sheet's lines in order.
- **Song timing workflow** ✅: blank words are timed **in the game** with `--mark-song {boss}`: calibrate with 8 clicks, then hold Space while each blank word is sung. It saves the labels file and rebuilds the song JSON itself. `--check-song {boss}` plays the fight with no damage to check by ear. Hand timing is not used.
- The game applies the labels file at load, so edits show on the next run.

### 6.5 Attacks, counters and sound effects ✅
- Attacks and counters are named ids referenced from the song data (`booger_flick`, `…_slapstick`, `…_gory`), resolved through `data/fight/registry.json`. Placeholders until the art exists.
- Shared sound effects in the registry, e.g. `wrong_scream`: a list of files picked at random.

### 6.6 Music sync ✅
- Clock time = playback position + time since last mix − output latency + `audio_offset`, never going backwards except on a seek.
- The audio clock and a silent clock share one interface; tests, captures and `--fight-auto` use the silent clock.

### 6.7 Global state (`GameState`)
| Variable / method | Notes |
|---|---|
| `hearts_halves` | 0–10 |
| `nunchi` | 0–7; `add_nunchi(n)` applies the cap and discards the rest |
| `ddeok` | Balance; `spend_ddeok(n)` only through the store layer |
| `secrets_held`, `secrets_known_by`, `leaks` | Cards, knowers, leak rule |
| `spawn_seed`, `collected`, `dropped`, `destroyed_notes` | Exploration and anti-farming |
| `inventory` | Equipment (bag, notebook), container contents (with a nested 필통), notebook pages |
| `notes` | The notes kept in the notebook |
| `talked` | Optional conversations whose stakes are spent |
| `shop_stock` | Per shop, per save |
| `scores`, `outcomes` | Best score and win type per boss |
| `progress` | `scene_01` → `sat_roam` → `scene_02` → `mon_walk` → `mon_roam` → `party` → `boss1_fight` → `boss1_done` |
| Snapshots | Fight start; party start (§7) |
| `damage(halves)`, `heal(halves)` | Clamp to 0–10; 0 triggers death (in a fight: the fight game over) |
| `lose_secret(card, by)`, `has_secret`, `knows`, `cards_known_by` | Unchanged |

### 6.8 Project folders ✅
```
res://
  addons/dialogue_manager/
  data/  config/ dialogue/ fight/ items/ maps/ scenes/ secrets/ shop/ songs/ spawns/
  maps/            # room scenes per map
  characters/      # 3D characters and animations (to come)
  audio/  songs/ sfx/
  art/             # textures, UI, fonts
  scenes/  scripts/  tools/  tests/
  docs/            # ignored by Godot
```

---

## 7. Saving ✅
- **Autosave** on room changes, scene starts, roam starts, the start of each pre-fight map and fight, and after a death reset. Launching resumes at the **start** of the saved progress step.
- **Checkpoints:** the start of **Scene 01** (deaths in Map 01); the start of **the party** (deaths in Map 02); the start of **each fight** (fight retries).
- The save is compact, **versioned** (currently **v4**) with a migration for each version, and written atomically with a `.bak`.
- **Settings** live in a separate `user://settings.cfg` (`quick_heal_order`). ❓ No settings menu yet.
- Tests, captures and scripted runs use a **sandbox** save and settings, never the player's.
- Off-chain saves only for now. ❓ Act carry-over; shared NHMH save.

---

## 8. UI, Input and Display ✅
- **Platform:** PC (Windows first; Linux).
- **Display:** live 3D at 1920×1080, Forward+.
- **HUD everywhere:** ❤️ hearts (with halves), 👀 눈치 (7 eye icons), 🍡 DDEOK (송편 icon), 🔒 cards. In fights, the lyric line and options appear on the 반주기 screen.
- **Korean** is primary. Player-facing Korean comes only from approved scripts and lists; key hints and dev screens are English placeholders until written.
- ❓ Final Korean font (Noto Sans KR is the placeholder). 🟡 Optional English subtitles via Godot's translation system.

---

## 9. Writer's Rules ✅

### 9.1 Scenes
1. **Every dialogue choice does exactly one thing:** +1 눈치, −1 card, −½ or −1 ❤️, or nothing.
2. Each forced choice point offers one good-read (눈치) answer.
3. **No placeholder names.** Every speaking character has a real name.
4. **No real names.** Satirical fictional names only.
5. **Violence wherever it fits.** Over-the-top, never apologized for.
6. Facts the user has confirmed or deliberately bent are noted in the script file, not re-checked.
7. Keep count of the 눈치 a stretch of forced scenes offers; at the cap of 7, extra is lost.

### 9.2 Songs
1. **Every blank does exactly one thing:** right = the word is sung and the counter plays; wrong = −1 heart.
2. Distractors must be plausible and teach something.
3. Blanks get harder phase by phase.
4. Lyrics never reference a boss's real life or 보람's secrets.
5. **Suno lyrics** carry no speaker names, no parentheses and no blank markers (Suno sings or says whatever is in the box).
6. Every sung word matches the game lyrics; timing labels are checked against them.

### 9.3 Maps
1. Every map has a **spot pool** large enough for random dealing.
2. Hidden spots and traps fit the place and the era.
3. Most traps cost ½ heart; 1-heart traps are rare. Traps can be limited to particular spots.
4. Secret notes help or teach; they never hand over answers.

---

## 10. Open Questions
1. Dodges: return as an optional feature?
2. 눈치 at the cap: keep "lost", or a new use later (temporary decision)?
3. NFT scope and any trade in non-commercial things (DDEOK session).
4. Bribes that change the story (DDEOK documents) in this game.
5. Item stacking (1 or 3); container downgrade triggers; more containers and notebooks.
6. What skills are; whether clothes have effects.
7. DDEOK amounts and prices after more playtesting.
8. Optional-conversation repeat lines; examinable objects and the era slang codex.
9. Per-attack game-over headlines.
10. Settings menu; controller; phone.
11. Act carry-over; shared NHMH save.
12. Final Korean font.
13. Props solid or not (with art).
