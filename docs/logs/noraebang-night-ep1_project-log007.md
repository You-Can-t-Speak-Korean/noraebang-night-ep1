# Noraebang Night Ep1 Project Log 007 — Steps 4d to 6b: the slice plays start to finish

*7–16 November 2026 · Noraebang Night · Episode 1 · Act 1: 국민학교 시대*
*Previous logs: 006 (6 Nov), 005, 004, 003, 002, 001*

> **Read this first in every new session.** Then read Logs 006, 005, 004, 003, 002 and 001 **in full** for anything this log doesn't change, then the documents in §2.
> Markers: ✅ decided · 🟡 suggested · ❓ open · 🔍 verify

---

## 0. Summary

- **The vertical slice plays from start to finish** (user playtest, 16 Nov): Scene 01 → Saturday roam → Scene 02 → Monday roam and the 문방구 → Scene 03, the party → the 은주 fight → results → summary → end card.
- Built this session: 4d (screams), 5a (item system), 5b (문방구), 6a (party map and Scene 03), 6b (the full chain).
- Written this session: Song Sheet 01 v0.3, Song Sheet Template v0.2, Scene 03 v0.1.
- **Big design decisions:**
  - 눈치 is non-commercial and no longer converts to DDEOK.
  - Containers are items; 보람 starts with none.
  - Dying at the party restarts the party.
- **Next:** confirm the 6a–6b push, then Systems Spec v0.5 to bring the many overrides together.

---

## 1. Workflow rules (additions)

| # | Rule |
|---|---|
| 29 | **Claude never rewrites a project log without the user's explicit approval** ✅ (user, 6 Nov). |
| 30 | **Claude Code prompts say: do not write project logs or any file in `docs/`.** In 6a, Claude Code wrote its own `docs/logs/project-log-007.md`; it was not committed. |
| 31 | **Move forward, don't risk working builds for tidiness** ✅ (user, 7 Nov). Example: the song builder still reads Song Sheet 01 v0.2 on purpose. |
| 32 | **Commit each step before running the next prompt.** 6a and 6b ended up in one commit because 6a's `git add` failed on a pathspec that matched nothing. |
| 33 | **Playtest checks that can't be done yet are deferred, not blockers** ✅ (user). |
| 34 | `git add` names files explicitly. Quoted json patterns (`"data/shop/*.json"`) are fine when a folder holds only new data files, but a pattern that matches nothing aborts the whole `git add`. |

---

## 2. Document map (changes since Log 006)

| Document | Where | Status |
|---|---|---|
| Song Sheet 01 v0.2 | `docs/songs/` | **Superseded** by v0.3. **Still read by `tools/build_song.gd` on purpose** (rule 31) |
| **Song Sheet 01 v0.3** | `docs/songs/` + Project `claude/` | **Current.** The song as built: 보람 sings, win rules, Suno, timing, screams |
| Song Sheet Template v0.1 | Project only | **Superseded** |
| **Song Sheet Template v0.2** | `docs/design/` + Project `claude/` | **Current.** Same layout as the game's sheet reader; Suno blocks; `--mark-song` workflow |
| **Scene 03 v0.1** 〈김은주 생일 파티〉 | `docs/scripts/` + Project `claude/` | **Current** (approved 15 Nov) |
| Systems Spec v0.4 | `docs/design/` | Current but heavily overridden (§4); v0.5 needed |
| DDEOK docs (Master Roadmap, Dev Decisions) | Project | Conflict: "눈치 max-out pays DDEOK" is no longer true in the game (§4.4) |
| `docs/logs/project-log-007.md` | Repo (untracked) | Written by Claude Code, not this log. Delete it |

---

## 3. What was built

| Step | Commit | Contents | Checks |
|---|---|---|---|
| 4c–4d | `eb53306` | The real song track, label timing, tap tool and audition, song plays out under results, **three random screams** (never the same twice in a row) | 1424 |
| 5a | Pushed (hash not recorded) | **Item system:** item data, containers (필통 / 책가방 / 공책), nesting, Tab inventory, pickup popups, E quick heal, settings file, revenge reward. Save v2 | 1578 |
| 5b | Pushed (hash not recorded) | **문방구:** shop data, store layer (`Store.buy`), shop panel, shopkeeper lines, stock per save. Save v3 | 1652 |
| 6a + 6b | **One commit, git block given 16 Nov. ❓ Confirm pushed** | **Map 02** (7 rooms), **Scene 03**, party finds and traps, party checkpoint, 눈치 overflow removed. Save v4. **The chain:** Monday exit → 「1979년 11월 3일 토요일」 → party → fight → results → summary → end card | 1888 (6a); 6b count not reported, 4 clean runs |

**Progress steps:** `scene_01` → `sat_roam` → `scene_02` → `mon_walk` → `mon_roam` → `party` → `boss1_fight` → `boss1_done`. The old `sat2_pending` end card is gone.

**Save versions:** v2 (inventory) → v3 (shop stock) → v4 (party checkpoint), each with a migration.

**New dev args:**
- `--give id,…`
- `--heal-order lowest_first|highest_first`
- `--ddeok N` (sandbox only)
- `--skip-to party|boss1_fight|boss1_done`
- captures: `--capture-items`, `--capture-shop`, `--capture-party`, `--capture-chain`

**New data:**
- `data/items/items.json`, `data/items/rewards.json`
- `data/shop/act1_munbanggu.json`
- `data/maps/map_02.json`, `data/spawns/map_02.json`
- `data/scenes/scene_03.json`, `data/dialogue/scene_03.dialogue`
- `user://settings.cfg`

---

## 4. Decisions and deviations (Spec v0.5 candidates)

### 4.1 Songs and documents
| # | Decision | Deviates from |
|---|---|---|
| 1 | Song Sheet 01 v0.3 records the song as built. The builder keeps reading v0.2 ✅ | — |
| 2 | Template v0.2 keeps the reader's layout (game lyrics first, 8-column blank table, `#n` loaded rows, `> *"…"*` game-over line) so song 2 needs no parser rewrite. Each new song still needs a small DEV step for the builder's settings (song id, files, attack ids) | Template v0.1 |
| 3 | The track's lyrics were pasted into Suno from Song Sheet 01 v0.2 §2, with the speaker names removed ✅ | — |
| 4 | Native-speaker review of Song Sheet 01 passed in full ✅ | — |
| 5 | The intro is spoken in the track's single voice. Accepted for now ✅ | Sheet's 은주 intro |

### 4.2 DDEOK and 눈치
| # | Decision | Deviates from |
|---|---|---|
| 6 | **The game stays off-chain until it is ready.** The first on-chain run is a test of buying and selling in the Noraebang Night stores; real on-chain comes after that passes ✅ | — |
| 7 | **DDEOK must have real value:** real power and ability in the game, but never a way to buy through it ✅ | — |
| 8 | **눈치 is non-commercial:** never sold, bought or traded. Earned only by reading the room ✅ | Spec §4.6, Log 004 §3 #1 |
| 9 | **눈치 no longer converts to DDEOK.** At the cap of 7, extra 눈치 is lost ✅ (temporary; tokenomics and cheat prevention) | Spec §2.2, DDEOK Dev Decisions ("눈치 max-out pays DDEOK") |
| 10 | Spec §2.2's "Act 1's forced scenes award exactly 7" no longer holds: Scenes 01–03 offer up to 8 forced 눈치 | Spec §2.2 |
| 11 | 🟡 NFTs only for durable, tradeable items (clothes, storage, maybe skills); consumables, stats and notes stay in-game. ❓ For a DDEOK session | DDEOK Dev Decisions §7 ("every buyable item is an NFT") |

### 4.3 Items and storage (5a)
| # | Decision | Deviates from |
|---|---|---|
| 12 | **Containers are items. 보람 starts with none** ✅. Bag slot: 필통 (4 slots), 책가방 (12, not in Act 1). Notebook slot: 공책 (3 pages) | Style Brief v0.3 (red 책가방 is visual only) |
| 13 | A 필통 can ride inside a 책가방, taking 3 of its slots (data) and keeping its own 4 | — |
| 14 | Containers can be upgraded or downgraded; a downgrade asks what to drop. What causes a downgrade is story, for later | — |
| 15 | **Notes live in the 공책.** Without one, or with it full, a note can be read, then 버린다 or 던져버린다 | — |
| 16 | **Health items go into slots**, not applied on pickup. With no bag or a full one, a popup offers 지금 쓴다 / 버린다 | Log 005 #7 |
| 17 | 버린다 leaves the item findable until 보람 leaves the map (day change) or dies. 던져버린다 destroys a note for good. No throw animation yet | — |
| 18 | **Tab** opens the inventory outside fights and dialogue. **E** uses a health item anywhere, fights included (the countdown keeps running). Order set by `quick_heal_order` (default lowest first: 반창고, then 빨간약) | — |
| 19 | `stack_max` = 1 for now (data). ❓ Maybe 3, after playtesting | — |
| 20 | Revenge win vs 은주 → 필통, only if 보람 has no bag | — |
| 21 | Approved UI text: 넣을 데가 없다. · 필통이 꽉 찼다. · 공책이 없다. · 공책이 꽉 찼다. · 아픈 데가 없다. · 지금 쓴다 · 버린다 · 던져버린다 · 공책에 넣는다 · 쓴다 · 읽는다 | — |

### 4.4 The 문방구 (5b)
| # | Decision | Deviates from |
|---|---|---|
| 22 | Stock: 필통 3 DDEOK ×1 · 공책 1 ×1 · 반창고 1 ×3 · 빨간약 2 ×2. No 눈치. Skills and clothes wait until they're defined | Spec §4.6 |
| 23 | Shopkeeper **고옥분**, shown as 문방구 할머니. Lines: 어서 오세요. · 뭐 줄까? · 옜다. · 돈이 모자라네. · 그건 다 팔렸어. · 넣을 데가 없잖아. 필통부터 사 가. (bag full: first sentence only) · 또 와라. ✅ | — |
| 24 | The shop checks money before space (kept as built) | — |
| 25 | Stock is per save, never restocks on reload, and is restored by a death reset. All purchases go through one store layer, ready for an on-chain backend | — |

### 4.5 The party and the chain (Scene 03, 6a–6b)
| # | Decision | Deviates from |
|---|---|---|
| 26 | Scene 03: two forced choices (the door, the presents) and one optional conversation with stakes (은주 아빠). New characters **황정숙** (은주 엄마) and **김만복** (은주 아빠, 사장님) ✅ | — |
| 27 | The phone call 「그 혼혈 애… 생각보다 깨끗해」 is kept as written ✅ | — |
| 28 | Party finds: same deal as the school. Traps only at the 장식장 (양주 bottle, 1 heart), the sofa (fork, ½) and the fridge (door on fingers, ½) | — |
| 29 | **Dying at the party restarts the party** (03-A) with the party-start snapshot ✅. Deaths in Map 01 still restart Scene 01. A relaunch at `party` also restarts 03-A, so forced choices can't be farmed | Spec §3.6, Log 004 #4 |
| 30 | The 문방구 is in Map 01 only; Monday afternoon is the last chance to shop ✅ | — |
| 31 | After the fight: results → aftermath → a summary (hearts, 눈치, DDEOK, lost cards, items) → "END OF BUILD — Boss 1 complete"; Enter starts a new game. The song plays on underneath | — |

---

## 5. Open (defaults in brackets)

1. ❓ **Confirm the 6a–6b commit was pushed.**
2. **Revenge reward:** Claude Code couldn't reproduce the missing 필통; the summary now shows it. Confirm in play.
3. **Not hand-tested:** E inside a fight, items restored on a fight retry, real mouse clicks, the song playing on through the summary and end card on real audio.
4. **Flaky test:** the Map 01 keycap check "while the text box is open the keycap is hidden" failed once in 6b.
5. ❓ NFT scope (decision 11) and whether 눈치 could ever be traded. If it ever is, buy-only is safer than buy-and-sell.
6. ❓ Stacking (decision 19), downgrade triggers, bigger notebooks, other storage types, skills, clothes.
7. A settings menu (only `user://settings.cfg` exists).
8. 던져버린다 throw animation; attack, counter and revenge visuals; per-attack game-over headlines (WRITE).
9. **Systems Spec v0.5** to absorb §4 and Logs 005–006. Also reconcile the DDEOK docs (decision 9).
10. 🔍 Scene 03 facts: bananas as a luxury in 1979; live TV coverage of the 3 Nov 1979 state funeral; adults calling the Derg 「공산당」; 「인제라」 as the spelling of injera.
11. **Housekeeping:**
    - delete Claude Code's `docs/logs/project-log-007.md`; add this log to `docs/logs/`;
    - check Logs 005 and 006 are in `docs/logs/`;
    - scrub and commit `CLAUDE.md`;
    - `docs/backups/` (the user's original timings: keep untouched) and the old labels copy in `docs/songs/`;
    - Project duplicates (root vs `claude/`).
12. Everything still open in Logs 006, 005 and 004.

---

## 6. Next steps

1. Confirm the 6a–6b push.
2. **Systems Spec v0.5** (WRITE / DEV).
3. Art and characters (FRONTEND), replacing the gray boxes.
4. Scene 00 rebuilt in 3D, or Boss 2 (정정훈 선생님): scripts, song sheet on Template v0.2, map.
