# Scene 01 — 김은주 Scene 1: "너 어디서 왔어?"

*Script v0.2 · Approved 26 October 2026 · Supersedes v0.1 (23 October 2026)*
*Act 1: 국민학교 시대 · Boss 1: 김은주*

> Production document. Changes are made by issuing a new version; v0.1 stays unchanged.
> All Korean needs **native-speaker review** before recording or release.

### What changed since v0.1
- **Map staging** (Systems Spec v0.4 §3.2, §3.7): the scene plays in Map 01, 1학년 3반, with movement locked and unlocked at set points.
- **01-A2** (new): 10 seconds of free movement before 은주 comes over.
- **01-F** (new): the Saturday afternoon roam; leaving through the 교문 ends the day.
- **Checkpoint**: the start of 01-A is the restart point after a death outside a fight.
- **Twins' surname 손** added to the character table.
- **Scene facts**: Scene 01 is the same Saturday morning as Scene 00's classroom part.
- Every approved Korean line from v0.1 is unchanged.

---

## Scene facts

| Field | Value |
|---|---|
| Date | Saturday 27 October 1979, 쉬는 시간, the same morning as Scene 00's attendance ✅ |
| Place | Map 01 — 1학년 3반; then the whole map (01-F) |
| map_day | `sat` |
| Boss in the room | 은주 — lost cards become known by `eunju` |
| Checkpoint | Start of 01-A = restart point after a death outside a fight |
| Follows | Scene 00 (attendance; 은주 turns and stares) |
| Leads to | Scene 02: 김은주 Scene 2 — 초대장 (Monday 29 Oct) |
| Choices | 3 choice points; up to +3 눈치 |

## Characters

| Name | Speaker label | Role |
|---|---|---|
| 장보람 | — | Protagonist |
| 김은주 | 은주 | Boss 1 |
| 손미숙 | 미숙 | 은주's friend; twin of 미경 |
| 손미경 | 미경 | 은주's friend; twin of 미숙 |
| 박철수 | 박철수 | Classmate (on the 떠든 사람 list) |
| 오동진 | 오동진 | Classmate (on the 떠든 사람 list) |
| 최은주 | 최은주 | Classmate |
| 한은주 | 한은주 | Classmate |
| 오경자 선생님 | — | 1학년 담임 (no lines in this scene) |

---

## Script

```
SCENE 01 — 김은주 SCENE 1: "너 어디서 왔어?"
Act 1 · Saturday 27 Oct 1979 · Map 01, 1학년 3반 · 쉬는 시간
Boss in the room: 은주 ($> GameState.set_boss("eunju"))
map_day: sat
Checkpoint: the start of 01-A is the restart point after a death outside a fight.

────────────────────────────────────────
01-A  RECESS                              (movement locked)
────────────────────────────────────────
[Fade in on 1학년 3반. 오경자 선생님 walks out the door.
 The TV still plays the mourning broadcast. Nobody watches it.
 박철수 and 오동진 play 딱지 by the back row.
 은주 sits at her desk with 미숙 and 미경.]

박철수:   오늘도 만화 안 해?
오동진:   몰라. 딱지나 해.

────────────────────────────────────────
01-A2  A FEW SECONDS FREE                 (movement unlocked)
────────────────────────────────────────
[보람 can walk and search the room.
 Trigger: 은주 gets up when 보람 comes within reach of her desk,
 or after 10 seconds, whichever comes first.]

────────────────────────────────────────
01-A3  은주 ARRIVES                        (movement locked to the end of 01-E)
────────────────────────────────────────
[은주 gets up. 미숙 and 미경 follow her. She stops in front of 보람,
 wherever 보람 is standing.]

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

────────────────────────────────────────
01-F  SATURDAY AFTERNOON                  (movement unlocked)
────────────────────────────────────────
[Fade. Saturday classes are over. The classroom is empty.
 보람 can roam Map 01 (Saturday deal; 2층 locked; 문방구 locked).
 Optional conversations: see Optional Conversations — Saturday v0.1.]
[Walking out through the 교문 ends the day.]

[Fade to black. Title card:]
1979년 10월 29일 월요일

→ SCENE 02: 김은주 Scene 2 — 초대장 (map_day: mon)
```

---

## Notes

- **Writer's rules (Systems Spec v0.4 §9.1):** every option does exactly one thing; each choice point has one 눈치 answer.
- **Register lesson:** 1C uses 존댓말 to a classmate. It's grammatically correct but socially submissive, so it costs 자존심.
- **Double losses:** if 자존심 is already lost, 1C and 2A cost nothing more.
- **Scene 00 condition (01-A3):** kept on purpose. It can't fire until Scene 00 is rebuilt, and a death currently resets 자존심. Whether the checkpoint keeps Scene 00's results is ❓, decided when Scene 00 is rebuilt.
- **History:** the assassination is on the evening of Friday 26 Oct 1979, as in history. The death was announced on the 5am radio news and in the government spokesman's 7:25am statement on 27 Oct, so a mourning broadcast on the classroom TV that Saturday morning is accurate (verified 26 Oct 2026).
- **"오늘도 만화 안 해?"** kept as approved. 🟡 "오늘은 만화 안 해?" was suggested, since Friday's cartoons aired before the shooting; raise it at native-speaker review.
- **Facts confirmed by the user (23 Oct 2026):** Saturday classes, 김은주 as a very common 1970s name, apartments with elevators, school bells.
- **For DEV (Step 3):** 01-A2 trigger = reach of 은주's desk or 10 s. 01-F end trigger = the 교문 exit. Date card text is game Korean.
