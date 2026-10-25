# Scene 02 — 김은주 Scene 2: 초대장

*Script v0.1 · Approved 24 October 2026*
*Act 1: 국민학교 시대 · Boss 1: 김은주*

> Production document. Changes are made by issuing a new version (v0.2…); this file stays unchanged.
> All Korean needs **native-speaker review** before recording or release.

---

## Scene facts

| Field | Value |
|---|---|
| Date | Monday 29 October 1979 |
| Place | 1학년 classroom before class; after school; a shop window |
| Boss in the room | 은주 — lost cards become known by `eunju`, except 1B (known by `hyunjeong`) |
| Debut | 함현정 |
| Follows | Scene 01: 김은주 Scene 1 — "너 어디서 왔어?" |
| Leads to | Boss 1 fight: 김은주 — 〈달님은 계란 후라이〉 at 은주's birthday party, Saturday 3 Nov 1979 (the day of the state funeral) |
| Choices | 3 choice points; up to +3 눈치 |

## Characters

| Name | Role |
|---|---|
| 장보람 | Protagonist |
| 김은주 | Boss 1 |
| 손미숙 | 은주's friend; twin of 미경 |
| 손미경 | 은주's friend; twin of 미숙 |
| 함현정 | 보람's best friend (debut). Her mother is 육성회 회장 (Boss 3) |
| 박철수 | Classmate |
| 오동진 | Classmate |
| 최은주 | Classmate |
| 한은주 | Classmate |
| 문태식 | TV news anchor |

---

## Script

```
SCENE 02 — 김은주 SCENE 2: 초대장
Act 1: 국민학교 시대 · Monday 29 Oct 1979 · 1학년 classroom, before class
Boss in the room: 은주 ($> GameState.set_boss("eunju"))
Debut: 함현정

────────────────────────────────────────
02-A  THE INVITATIONS
────────────────────────────────────────
[은주 walks between the desks with a stack of pink envelopes.
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
02-E  HANDOFF
────────────────────────────────────────
[After school. 현정 walks with 보람.]

현정:    토요일에 나도 가. 같이 가자.
현정:    (quietly) 근데… 은주네 집에 반주기 있대. 노래 시킬 거야.

[A TV in a shop window. 문태식 reads the news.]
문태식:  …고 박뻥희 대통령의 국장은 오는 토요일에 거행됩니다.

→ BOSS 1: 김은주 — 〈달님은 계란 후라이〉 at 은주's birthday party
```

---

## Notes

- **Writer's rule (Systems Spec v0.1 §2.5):** every option does exactly one thing. Each choice point has one 눈치 answer.
- **Language (TOPIK 2):**
  - **2C** teaches the vocative ending: -아 after a consonant (현정아), -야 after a vowel (은주야). The wrong form earns the title joke, "너 한국말 못해?"
  - **"저요!"** is how kids answer a roll call.
  - **The form** is reading practice.
- **The form** parodies the 가정환경조사서, the household survey schools sent home.
- **The mother's job stays hidden.** It is still undecided, so 3A costs the card without the game showing what 보람 wrote.
- **1B leak rule:** a card told to 현정 becomes known to 현정 엄마 (Boss 3). Approved; goes into Systems Spec v0.2.
- **Facts:** the state funeral on 3 Nov 1979 is confirmed. **Home 반주기 machines are a deliberate anachronism** (they appeared in 1986); the story bends this on purpose.
