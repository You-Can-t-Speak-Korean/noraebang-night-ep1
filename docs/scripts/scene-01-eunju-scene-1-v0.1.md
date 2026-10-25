# Scene 01 — 김은주 Scene 1: "너 어디서 왔어?"

*Script v0.1 · Approved 23 October 2026*
*Act 1: 국민학교 시대 · Boss 1: 김은주*

> Production document. Changes are made by issuing a new version (v0.2…); this file stays unchanged.
> All Korean needs **native-speaker review** before recording or release.

---

## Scene facts

| Field | Value |
|---|---|
| Date | Saturday 27 October 1979 (the morning after Scene 00) ✅ |
| Place | 1학년 classroom, 쉬는 시간 |
| Boss in the room | 은주 — lost cards become known by `eunju` |
| Follows | Scene 00 (attendance; 은주 turns and stares) |
| Leads to | Scene 02: 김은주 Scene 2 — the invitation trap |
| Choices | 3 choice points; up to +3 눈치 |

## Characters

| Name | Role |
|---|---|
| 장보람 | Protagonist |
| 김은주 | Boss 1 |
| 미숙 | 은주's friend |
| 미경 | 은주's friend |
| 박철수 | Classmate (on the 떠든 사람 list) |
| 오동진 | Classmate (on the 떠든 사람 list) |
| 최은주 | Classmate |
| 한은주 | Classmate |
| 오경자 선생님 | 1학년 담임 |

---

## Script

```
SCENE 01 — 김은주 SCENE 1: "너 어디서 왔어?"
Act 1: 국민학교 시대 · Saturday 27 Oct 1979 · 1학년 classroom, 쉬는 시간
Boss in the room: 은주 ($> GameState.set_boss("eunju"))

────────────────────────────────────────
01-A  RECESS
────────────────────────────────────────
[오경자 선생님 leaves. The TV still plays the mourning broadcast.
 Nobody watches it.]

박철수:   오늘도 만화 안 해?
오동진:   몰라. 딱지나 해.

[은주 gets up. 미숙 and 미경 follow her. She stops at 보람's desk.]

은주:     야. 너.

[Only if 자존심 was lost in Scene 00:]
은주:     아까 반장한테 "미안해…" 했지? (미숙 and 미경 giggle)

은주:     너 어디서 왔어?

────────────────────────────────────────
01-B  CHOICE 1 — where from
────────────────────────────────────────
▸ A  "서울에서 왔어."
       → +1 👀 눈치
       은주:  흥. 서울 사람 같지 않은데.

▸ B  "우리 아빠는 에티오피아 사람이야."
       → −1 🔒 아빠 나라
       은주:  에티오피아? 그게 어디야?
       미숙:  아프리카래!
       은주:  아프리카에도 학교 있어?

▸ C  "서울에서 왔어요."
       → −1 🔒 자존심
       은주:  왜 나한테 존댓말 해? …그래. 계속 그렇게 해.

▸ D  "너는?"
       → nothing
       은주:  나? 우리 집은 아파트야. 엘리베이터도 있어.

────────────────────────────────────────
01-C  CHOICE 2 — the name
────────────────────────────────────────
[은주 grabs 보람's 명찰 and reads it out loud for the class.]

은주:     장. 보. 람? 보람이 뭐야? 무슨 이름이 그래?
[Some of the class laughs.]

▸ A  "헤헤… 좀 이상하지?"
       → −1 🔒 자존심
       은주:  응. 이상해.

▸ B  "우리 반에 은주는 세 명이나 있잖아."
       → +1 👀 눈치
       [최은주 and 한은주 raise their hands.]
       최은주:  나도 은주야!
       한은주:  나도!
       [The class laughs at 은주 instead.]
       은주:   …시끄러워!

▸ C  (아무 말도 안 한다)
       → nothing
       [은주 drops the 명찰 on the floor.]

────────────────────────────────────────
01-D  CHOICE 3 — the money question
────────────────────────────────────────
은주:     너희 엄마는 뭐 해? 월급 얼마 받아?

▸ A  "몰라. 그건 우리 집 비밀이야."
       → +1 👀 눈치
       은주:  치. 가난해서 그렇지?

▸ B  "몰라… 근데 엄마가 아빠보다 많이 벌어."
       → −1 🔒 엄마 월급
       은주:  진짜? 엄마가 아빠보다 많이 벌어?
       미경:  너희 아빠 불쌍하다~

▸ C  "우리 아빠는 소주 세 병 마셔!"
       → −1 🔒 아빠 주량
       은주:   …그게 자랑이야?
       박철수: (from across the room) 우리 아빠는 다섯 병!
       오동진: 우리 아빠는 여섯 병!

▸ D  "너희 엄마는?"
       → nothing
       은주:  우리 엄마는 일 안 해. 우리 아빠가 사장님이야.

────────────────────────────────────────
01-E  HANDOFF
────────────────────────────────────────
[The bell rings. 은주 walks back to her seat.]

미숙:    (whispering) 은주야, 쟤도 생일 파티에 불러?
은주:    (looks back at 보람 and smiles) …생각해 볼게.

→ SCENE 02: 김은주 Scene 2 — the invitation trap (함현정 debuts)
```

---

## Notes

- **Writer's rule (Systems Spec v0.1 §2.5):** every option does exactly one thing. Each choice point has one 눈치 answer.
- **Register lesson:** 1C uses 존댓말 to a classmate. It's grammatically correct but socially submissive, so it costs 자존심.
- **Double losses:** if 자존심 is already lost, 1C and 2A cost nothing more. Approved as is.
- **Facts:** verified by the user, 23 Oct 2026 (Saturday classes, 김은주 as a very common 1970s name, apartments with elevators, school bells).
- **Not yet decided:** surnames for 미숙 and 미경.
