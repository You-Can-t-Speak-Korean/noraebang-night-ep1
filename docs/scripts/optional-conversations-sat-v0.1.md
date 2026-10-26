# Optional Conversations — Saturday 27 Oct 1979

*Version 0.1 · Approved 26 October 2026*
*Act 1: 국민학교 시대 · Map 01 · During Scene 01's 01-F (Saturday afternoon roam)*

> Production document. Changes are made by issuing a new version.
> All Korean needs **native-speaker review** before recording or release.

## Rules (Systems Spec v0.4 §3.4)
- Mostly flavor; about 1 in 5 has stakes (this set: 1 in 3, as a sample).
- No markers show which conversations matter.
- Stakes pay out **once per save**.
- 🟡 After the first time, flavor conversations play a one-line repeat (to be written).
- Every choice does exactly one thing (§9.1).

| Id | Where | Who | Type |
|---|---|---|---|
| OC-01 | 운동장 | 박철수, 오동진 | Flavor |
| OC-02 | 현관 신발장 | 윤상훈 (반장) | Stakes: +1 눈치 or −1 자존심 |
| OC-03 | 교무실 | 오경자 선생님 | Flavor |

---

## Script

```
OPTIONAL CONVERSATIONS — Saturday 27 Oct 1979 (during 01-F)

────────────────────────────────────────
OC-01  딱지 · 운동장 · 박철수, 오동진          flavor (no choice)
────────────────────────────────────────
[철수 and 동진 slap 딱지 on the dirt. 동진's palm is raw and bleeding a little.]

철수:   넘어갔다! 내 꺼야.
동진:   에이…
철수:   (lowers his voice) 야, 대통령 죽었대.
동진:   그럼 이제 누가 대통령 해?
철수:   몰라. 우리 아빠가 아무 말도 하지 말래.
동진:   (looks around, then whispers) …딱지나 해.

────────────────────────────────────────
OC-02  떠든 사람 · 현관 신발장 · 윤상훈 (반장)  STAKES (once per save)
────────────────────────────────────────
[상훈 is changing his shoes at the 신발장. He has a small notebook.]

상훈:   장보람. 너 아까 떠들었지? 월요일에 선생님한테 말할 거야.

▸ A  "그럼 은주 이름도 써. 은주가 제일 떠들었잖아."
       → +1 👀 눈치
       상훈:  (glances around) …은주는 안 돼. 은주네 아빠 사장님이야.
       [He closes the notebook without writing anything.]

▸ B  "미안해… 다시는 안 떠들게."
       → −1 🔒 자존심
       상훈:  그래. 반성해.

▸ C  "알았어."
       → nothing
       상훈:  월요일에 보자.

────────────────────────────────────────
OC-03  가정통신문 · 교무실 · 오경자 선생님      flavor (no choice)
────────────────────────────────────────
[오경자 marks homework. The 사랑의 매 rests on her desk.
 A fly lands on the desk. Without looking up, she crushes it with the 매. Splat.]

오경자: 보람이 아직 안 갔니? 토요일인데 얼른 집에 가야지.
오경자: 너희 아빠는 한국말 잘하시니?
오경자: …가정통신문은 엄마한테 드려라. 알았지?
[She wipes the 매 on the homework.]
```

---

## Notes

- **Satire targets:** adult silence after the assassination (OC-01), unequal rule enforcement (OC-02), casual nosiness about 보람's father (OC-03).
- **Speech levels:** children use 반말 with each other; 상훈's "반성해" is a kid parroting teacher-speak. 오경자 speaks to a child in 해라체 (드려라) and uses honorifics for the father (하시니).
- **Echo:** OC-01 ends on 동진's "딱지나 해", the same words as Scene 01's opening.
- 🔍 **가정통신문:** not yet verified as in use in 1979. Check before release; fallback wording to be chosen at native-speaker review.
- **For DEV (Step 3):** OC-02's stakes go in `GameState.talked` (`oc02_sangun_sat`). OC-01 and OC-03 have no state effect.
