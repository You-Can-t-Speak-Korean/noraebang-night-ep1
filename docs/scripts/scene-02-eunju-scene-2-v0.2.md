# Scene 02 — 김은주 Scene 2: 초대장

*Script v0.2 · Approved 26 October 2026 · Supersedes v0.1 (24 October 2026)*
*Act 1: 국민학교 시대 · Boss 1: 김은주*

> Production document. Changes are made by issuing a new version; v0.1 stays unchanged.
> All Korean needs **native-speaker review** before recording or release.

### What changed since v0.1
- **Map staging** (Systems Spec v0.4 §3.7): 02-A to 02-D play in 1학년 3반 with movement locked; 02-E is a walk with 현정 following, with lines on triggers.
- **02-F** (new): the Monday afternoon roam; walking to the far end of the 골목길 ends the day.
- **문방구 unlocks** at the end of 02-E.
- Every approved Korean line from v0.1 is unchanged. The only new Korean is the date card.

---

## Scene facts

| Field | Value |
|---|---|
| Date | Monday 29 October 1979 |
| Place | Map 01 — 1학년 3반 before class; after school, 1층 복도 → 현관 → 운동장 → 교문 → 골목길; then the whole map |
| map_day | `mon` (2층 open; 문방구 locked until the end of 02-E) |
| Boss in the room | 은주 — lost cards become known by `eunju`, except 1B (known by `hyunjeong`, leaks to 현정 엄마) |
| Debut | 함현정 |
| Follows | Scene 01: 김은주 Scene 1 — "너 어디서 왔어?" |
| Leads to | Boss 1 pre-fight map: 은주's party, Saturday 3 Nov 1979 (the day of the state funeral) |
| Choices | 3 choice points; up to +3 눈치 |

## Characters

| Name | Speaker label | Role |
|---|---|---|
| 장보람 | — | Protagonist |
| 김은주 | 은주 | Boss 1 |
| 손미숙 | 손미숙 | 은주's friend; twin of 미경 |
| 손미경 | 손미경 | 은주's friend; twin of 미숙 |
| 함현정 | 현정 | 보람's best friend (debut). Her mother is 육성회 회장 (Boss 3) |
| 박철수 | 박철수 | Classmate |
| 오동진 | 오동진 | Classmate |
| 최은주 | 최은주 | Classmate |
| 한은주 | 한은주 | Classmate |
| 문태식 | 문태식 | TV news anchor |

---

## Script

```
SCENE 02 — 김은주 SCENE 2: 초대장
Act 1 · Monday 29 Oct 1979 · Map 01
Boss in the room: 은주 ($> GameState.set_boss("eunju"))
Debut: 함현정
map_day: mon   (2층 open; 문방구 locked until the end of 02-E)

────────────────────────────────────────
02-A  THE INVITATIONS   1학년 3반, before class   (movement locked to the end of 02-D)
────────────────────────────────────────
[Fade in after the Monday title card. 보람 is at her desk.
 은주 walks between the desks with a stack of pink envelopes.
 손미숙 and 손미경 follow her. 미경 carries the box.]

은주:    자, 내 생일 초대장이야! 이름 부르면 손 들어!
은주:    박철수!
박철수:  저요!
은주:    오동진!
오동진:  저요!
은주:    최은주! 한은주!
최은주·한은주: 저요!
은주:    함현정!

[The girl at the desk next to 보람 raises her hand. This is 현정.]

은주:    현정이는 특별히 금색 봉투. (to the class) 현정이 엄마는 육성회 회장이잖아.

[은주 walks past 보람's desk without looking. She hands out the rest.
 One envelope is left. She puts it in her pocket.]

────────────────────────────────────────
02-B  CHOICE 1 — 현정
────────────────────────────────────────
[현정 leans over to 보람.]

현정:    나 함현정. 너 보람이지?
현정:    은주 원래 저래. 신경 쓰지 마.
현정:    (holds out a candy) 이거 먹어. 쫀드기.
현정:    근데 너희 집 어디야? 이따 같이 가자.

▸ A  "학교 앞 문방구에서 만나자."
       → +1 👀 눈치
       현정:  좋아!

▸ B  "우리 집은 언덕 위에 있어. 파란 대문 집이야."
       → −1 🔒 우리 집  (known by 현정 → leaks to 현정 엄마)
       현정:  파란 대문? 우리 엄마한테 말해 줘야지!

▸ C  "응, 좋아!"
       → nothing
       현정:  그럼 이따 보자!

────────────────────────────────────────
02-C  CHOICE 2 — the last invitation
────────────────────────────────────────
[은주 goes to the front of the class and takes the last envelope out
 of her pocket.]

은주:    마지막 초대장은… 장보람!
[The whole class turns around.]
은주:    근데 그냥은 안 줘. "은주 공주님" 하고 불러 봐.

▸ A  "은주 공주님."
       → −1 🔒 자존심
       은주:  (smiling) 착하네.

▸ B  "은주야, 그냥 줘."
       → +1 👀 눈치
       은주:  …치. 여기.

▸ C  "은주아, 그냥 줘."
       → −1 🔒 자존심
       손미경:  은주아? 너 한국말 못해?
       [The class laughs.]

────────────────────────────────────────
02-D  CHOICE 3 — the form
────────────────────────────────────────
[Inside the envelope there is no invitation. There is a form.]

        ┌──────────────────────────┐
        │   생일 파티 참가 신청서    │
        │   이름: ______            │
        │   아빠 직업: ______       │
        │   엄마 직업: ______       │
        │   우리 집 TV: 컬러 / 흑백 │
        │   선물: ______ 원짜리     │
        └──────────────────────────┘

은주:    다 써. 지금. 안 쓰면 못 와.

▸ A  (다 솔직하게 쓴다)
       → −1 🔒 엄마 일
       [은주 reads it. Her eyes widen. The twins lean in.]
       손미숙·손미경:  …진짜?
       은주:  흥. 그럴 줄 알았어.
       [The game never shows what 보람 wrote.]

▸ B  (쓴다: "은주네 컬러 TV는 왜 흑백으로 나와?")
       → +1 👀 눈치
       [박철수 reads it over her shoulder, out loud. The class laughs.]
       은주:  아, 아직 컬러 방송을 안 해서 그런 거야!

▸ C  (이름만 쓰고 돌려준다)
       → nothing
       은주:  …뭐, 됐어.

[All branches:]
은주:    토요일 두 시. 꼭 와. 선물은 비싼 걸로.

[Taunts, only for cards 은주 knows:]
  아빠 나라  → 손미숙: 너희 아빠도 와?
               손미경: 아프리카 사람 진짜 보고 싶다!
  아빠 주량  → 은주:  너희 아빠는 오지 마. 소주 세 병 마시잖아.
  엄마 월급  → 은주:  선물은 엄마 월급으로 사 와. 많이 번다며?
  자존심     → 은주:  올 때 존댓말 잊지 마.

────────────────────────────────────────
02-E  WALKING HOME WITH 현정                       (movement unlocked)
────────────────────────────────────────
[Fade. After school. 현정 waits at the classroom door and follows 보람.
 보람 walks: 1층 복도 → 현관 → 운동장 → 교문 → 골목길.
 Detours are allowed (Monday deal; 2층 open). 현정 follows everywhere.]

[Trigger: entering the 현관]
현정:    토요일에 나도 가. 같이 가자.

[Trigger: reaching the 교문]
현정:    (quietly) 근데… 은주네 집에 반주기 있대. 노래 시킬 거야.

[Trigger: passing the 전파사 door in the 골목길. A TV in its window.
 문태식 reads the news.]
문태식:  …고 박뻥희 대통령의 국장은 오는 토요일에 거행됩니다.

[현정 waves and goes home. The 문방구 door unlocks.]

────────────────────────────────────────
02-F  MONDAY AFTERNOON                             (movement unlocked)
────────────────────────────────────────
[보람 can roam Map 01 and visit the 문방구 (shop arrives in Build Step 5).]
[Walking to the far end of the 골목길 (going home) ends the day.]

[Fade to black. Title card:]
1979년 11월 3일 토요일

→ BOSS 1 pre-fight map: 은주's party (Build Step 6)
```

---

## Notes

- **Writer's rules (Systems Spec v0.4 §9.1):** every option does exactly one thing; each choice point has one 눈치 answer.
- **Language (TOPIK 2):**
  - **2C** teaches the vocative ending: -아 after a consonant (현정아), -야 after a vowel (은주야). The wrong form earns the title joke, "너 한국말 못해?"
  - **"저요!"** is how kids answer a roll call.
  - **The form** is reading practice.
- **The form** parodies the 가정환경조사서, the household survey schools sent home.
- **The mother's job stays hidden.** It is still undecided, so 3A costs the card without the game showing what 보람 wrote.
- **1B leak rule:** a card told to 현정 becomes known to 현정 엄마 (Boss 3).
- **Continuity (accepted as is):** if the player picks 1A ("학교 앞 문방구에서 만나자"), 현정 still walks with 보람 from the classroom.
- **Facts:** the state funeral on Saturday 3 Nov 1979 is confirmed. **Home 반주기 machines are a deliberate anachronism** (they appeared in 1986).
- **For DEV (Step 3):** 02-E triggers at the 현관 entry, the 교문, and the 전파사 door in the 골목길 (TV prop there). 문방구 unlocks after the TV line. 02-F end trigger = a new "home" exit at the far end of the 골목길. No free seconds in the Monday morning.
