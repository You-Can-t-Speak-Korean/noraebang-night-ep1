# Scene 03 — 김은주 생일 파티 (Boss 1 pre-fight map)

*Script v0.1 · Approved 15 November 2026*
*Act 1: 국민학교 시대 · Boss 1: 김은주*

> Production document. Changes are made by issuing a new version.
> All Korean needs **native-speaker review** before recording or release.
> ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

---

## Scene facts

| Field | Value |
|---|---|
| Date | Saturday 3 November 1979, the day of the state funeral ✅ |
| Place | Map 02 — 은주네 아파트: elevator, corridor, 현관, 거실, 부엌, 복도, 화장실 |
| map_day | `party` |
| Boss in the room | 은주 — lost cards become known by `eunju` |
| Follows | Scene 02 (title card 「1979년 11월 3일 토요일」) |
| Leads to | Boss 1 fight: 〈달님은 계란 후라이〉 |
| Choices | 2 forced choice points (up to +2 눈치); 1 optional conversation with stakes (+1 눈치 or −1 card) |
| 눈치 note | 눈치 no longer converts to DDEOK. At the cap of 7, extra 눈치 is lost ✅ (temporary decision, 15 Nov 2026) |

## Characters

| Name | Speaker label | Role |
|---|---|---|
| 장보람 | — | Protagonist |
| 김은주 | 은주 | Boss 1 |
| 황정숙 | 은주 엄마 | 은주's mother (new) |
| 김만복 | 은주 아빠 | 은주's father, the 사장님 (new) |
| 함현정 | 현정 | 보람's best friend |
| 손미숙 | 미숙 | 은주's friend; twin of 미경 |
| 손미경 | 미경 | 은주's friend; twin of 미숙 |
| 박철수 | 철수 | Classmate |
| 오동진 | 동진 | Classmate |
| 최은주 | 최은주 | Classmate |
| 한은주 | 한은주 | Classmate |
| 문태식 | 문태식 | TV news anchor |

---

## Script

```
SCENE 03 — 김은주 생일 파티 (Boss 1 pre-fight map)
Act 1 · Saturday 3 Nov 1979, the day of the state funeral · Map 02: 은주네 아파트
Boss in the room: 은주 ($> GameState.set_boss("eunju"))
map_day: party
Follows: Scene 02 (title card 「1979년 11월 3일 토요일」)   Leads to: Boss 1 fight 〈달님은 계란 후라이〉

────────────────────────────────────────
03-A  THE ELEVATOR                              (movement unlocked)
────────────────────────────────────────
[The elevator doors open. 보람 and 현정 step out. 현정 hugs a big box
 with a ribbon. 보람 holds a small one wrapped in newspaper.]

현정:    와, 엘리베이터 진짜 빠르다!
현정:    너 선물 뭐 샀어? (looks at the newspaper) …아, 귀엽다.

[보람 walks the corridor to the door. Trigger: reaching the door.]

────────────────────────────────────────
03-B  THE DOOR — CHOICE 1                       (movement locked)
────────────────────────────────────────
[은주 엄마 opens the door: fur collar, pearls, too much perfume.
 은주 runs up behind her. Inside, the color TV shows the funeral in black and white.]

은주 엄마:  어머, 현정이 왔구나! 엄마는 잘 계시지? 들어와, 들어와.
[She looks 보람 up and down.]
은주 엄마:  …그리고 너는? 아, 네가 그 보람이구나. 은주한테 얘기 많이 들었다.
은주 엄마:  엄마는 같이 안 오셨니?

▸ A  "안녕하세요. 초대해 주셔서 감사합니다."
       → +1 👀 눈치
       은주 엄마:  (a little surprised) …어머, 인사성은 밝네. 들어와.

▸ B  "엄마는 토요일에도 공장에 가세요."
       → −1 🔒 엄마 일
       은주 엄마:  공장? …그렇구나. (to 은주, not quietly) 은주야, 쟤 옆에 앉지 마.

▸ C  "죄송해요… 엄마는 못 오세요."
       → −1 🔒 자존심
       은주 엄마:  (smiling) 죄송할 건 없지. 원래 그런 집도 있는 거야.

▸ D  (말없이 고개만 숙인다)
       → nothing
       은주 엄마:  어머, 말을 못 하니? …들어와.

────────────────────────────────────────
03-C  THE PRESENTS — CHOICE 2                   (movement locked)
────────────────────────────────────────
[The 거실: a 장식장 full of 양주, a sofa, a fridge, a big cake, the 반주기
 by the TV. 박철수, 오동진, 최은주, 한은주, 손미숙, 손미경 on the floor.
 은주 아빠 on the sofa with a glass of 양주.]

문태식:  (TV) …고 박뻥희 대통령의 국장이 엄숙히 거행되고 있습니다.
[Nobody looks.]

은주:    자, 선물! 현정이 거 먼저!
[현정's box: a doll with real hair. 은주 squeals.]
은주:    (picks up 보람's package with two fingers) 이건 뭐야? 신문지야?
[Inside: a set of pencils.]
은주:    연필? (to the room) 얘는 연필 사 왔대!
[The twins laugh.]

▸ A  "그거 우리 선생님이 쓰는 연필이랑 똑같은 거야."
       → +1 👀 눈치
       은주:  …진짜? (slips the pencils into her pocket)

▸ B  "우리 집에선 생일에 인제라 먹어. 이런 케이크 처음 봐."
       → −1 🔒 우리 집
       은주:  인제라? 그게 뭐야? 이름도 이상해.

▸ C  "미안해… 비싼 거 못 사서."
       → −1 🔒 자존심
       은주:  (smiling) 괜찮아. 엄마가 그러는데, 원래 그런 집도 있대.

▸ D  (아무 말도 안 한다)
       → nothing
       은주:  흥. (tosses the pencils onto the pile)

[Taunts, only for cards 은주 knows:]
  엄마 월급  → 은주:    엄마가 돈 많이 번다며? 근데 연필이야?
  아빠 나라  → 손미숙:  아프리카에도 연필 있어?
  엄마 일    → 은주:    공장에서 가져온 거 아니야?
  자존심     → 은주:    고맙다고 해 봐. 존댓말로.

────────────────────────────────────────
03-D  THE PARTY                                 (movement unlocked)
────────────────────────────────────────
[보람 can roam the apartment: 거실, 부엌, 복도, 화장실. Hiding spots and traps
 per the map (DEV). Optional conversations below. Entering the 화장실 → 03-E.]

OC-P1  은주 아빠 · sofa                          STAKES (once per save)
[은주 is listening from the cake table.]
은주 아빠:  어이, 꼬마. 이리 와 봐. (squints) 너희 아빠는 술 좀 하시냐?
  ▸ A  "저는 어린이라서 잘 몰라요."
         → +1 👀 눈치
         은주 아빠:  하하! 똑똑하네. 우리 은주보다 낫다.
  ▸ B  "우리 아빠는 소주 세 병 마셔요!"
         → −1 🔒 아빠 주량
         은주 아빠:  세 병? 하하, 장사네! 은주야, 들었냐?
  ▸ C  (고개만 끄덕인다)
         → nothing
         은주 아빠:  그래, 남자는 술이지. (falls asleep with the glass in his hand)

OC-P2  박철수, 오동진 · fridge                     flavor
철수:   야, 냉장고에 바나나 있다!
동진:   바나나? 진짜? 나 바나나 한 번도 안 먹어 봤어.
철수:   하나만 먹자.
동진:   (slams the fridge) 은주 엄마 온다!

OC-P3  최은주, 한은주 · by the TV                  flavor
최은주:  은주네 텔레비전 컬러래.
한은주:  근데 왜 흑백이야?
최은주:  몰라. 비싼 건 원래 그런가 봐.

OC-P4  현정 · near the 복도                        flavor
현정:   보람아, 화장실은 저쪽이야. 나 아까 가 봤는데, 변기 뚜껑이 털로 돼 있어.

────────────────────────────────────────
03-E  THE BATHROOM — WALKING BACK               (movement unlocked)
────────────────────────────────────────
[보람 goes into the 화장실. Fade. Later: she comes out into the 복도.
 Through the kitchen door, 은주 엄마 is on the phone.]

은주 엄마:  (on the phone) …응, 왔어. 그 혼혈 애. …아니, 생각보다 깨끗해.

[Only for cards 은주 knows:]
  아빠 나라  → 은주 엄마:  에티오피아래. 거기 지금 공산당이잖아.
  엄마 일    → 은주 엄마:  엄마는 공장 다닌대.
  아빠 주량  → 은주 엄마:  아빠는 술꾼이고.

은주 엄마:  …응, 끊어. 장기자랑 시작한대.

[Trigger: entering the 거실.]

────────────────────────────────────────
03-F  장기자랑                                    (movement locked)
────────────────────────────────────────
[은주 has the 반주기 mic. The guests sit on the floor.]

은주:    이제 장기자랑! 장보람, 너부터.
[She punches in a number. 〈달님은 계란 후라이〉 comes up on the 반주기 screen.]
[보람 hesitates.]
은주:    이 노래 몰라? 이 노래 모르는 애는… 죽어야 돼.
[The lights flicker. The funeral march on the TV warps. Reality freezes.]

→ BOSS 1 FIGHT: 〈달님은 계란 후라이〉
```

---

## Notes

- **Writer's rules (Systems Spec v0.4 §9.1):** every option does exactly one thing; each choice point has one 눈치 answer.
- **눈치 total:** Scenes 01–03 now offer up to 8 forced 눈치 (3 + 3 + 2). At the cap of 7 the extra is lost, since 눈치 no longer converts to DDEOK ✅. This replaces Spec §2.2 "Act 1's forced scenes award exactly 7".
- **Who learns lost cards:** 은주 is at the door in 03-B, opens the presents in 03-C and listens from the cake table in OC-P1, so every lost card becomes known by `eunju`.
- **Conditional lines** (taunts in 03-C, the phone call in 03-E) never offer choices and never change state (Spec §4.4).
- **03-F** uses the two trigger lines from Systems Spec v0.4 §3.5, word for word.
- **Callbacks:** 은주 엄마's 「말을 못 하니?」 (03-B D) echoes the title joke. 은주's 「엄마가 그러는데, 원래 그런 집도 있대」 (03-C C) shows where she learned her mother's line.
- **Satire:** the phone call (03-E) is deliberately ugly adult nosiness and racism. Kept as written ✅ (user, 15 Nov 2026).
- **Speech levels:** children use 반말 with each other; 보람 uses 존댓말 to adults; adults use 반말 to children.
- **Traps and hiding spots** (the 장식장 with the 양주, under the sofa, the fridge) are set in the map's spot pool, not in this script.
- **Facts:** the state funeral on Saturday 3 Nov 1979 is confirmed. Home 반주기 machines are a deliberate anachronism.
- 🔍 Bananas as a luxury in a rich 1979 home.
- 🔍 Live TV coverage of the state funeral on 3 Nov 1979.
- 🔍 1970s adults calling the Derg 「공산당」.
- 🔍 「인제라」 as the Korean spelling of injera.
