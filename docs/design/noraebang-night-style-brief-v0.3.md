# Noraebang Night — Style Brief

*Version 0.3 · 25 October 2026 · Supersedes v0.2 (24 October 2026)*
*Applies to: Act 1 style test, then the whole game unless a later version replaces it.*

> Production document. Changes are made by issuing a new version; v0.1 and v0.2 stay unchanged.

### What changed since v0.2
- §8 **Gore** is no longer confined to fights: violence appears wherever it fits, including exploration traps (Systems Spec v0.4).
- §8 adds the **gore scale** (½-heart vs 1-heart hits) and §9 adds the **HUD** (hearts with halves always on screen).
- Everything else is unchanged from v0.2 (live 3D, Forward+, side-on camera, look, proportions, 보람's design rules, lighting, palette, materials).

---

## 1. One-line look
A realistic cartoon diorama of 1979 Korea, lit like a nightmare. Familiar places, slightly wrong. Reference for mood, proportion and camera: *Little Nightmares*.

## 2. Proportions — the core idea
- **Children:** small, big heads (~4 heads tall), readable faces.
- **Adults:** oversized and looming. Heavy, doughy or stretched; faces a little too big, hands a little too large.
- The camera never lets 보람 feel big.

## 3. 보람 — design rules
- 7 years old at the start of Act 1 (13 at the end). Curly dark hair, warm brown skin, expressive eyes.
- The grotesque exaggeration applies to her tormentors, **never to her ethnic features**. She is drawn with care; the adults are the monsters.
- 1979 school clothes: knitted vest, white collar, 명찰 name tag, red 책가방. Clothes change as she ages and can be bought at the 문방구.

## 4. Camera
- Side-on, slightly high, like looking into a dollhouse. Rooms framed as stage sets.
- The camera follows 보람 left and right through connected rooms, with fixed framing per room.
- Fights use a fixed stage camera.

## 5. Lighting
One dominant light source per room (window, fluorescent tube, TV glow, a single lamp). Deep shadows, haze or dust in the air. Adults' faces often half in shadow.

## 6. Palette — 1979, muted
- Cream walls, varnished wood, blackboard green, olive, mustard, cold TV grey. Low saturation.
- Accents, used sparingly: blood red, 태극기 red and blue, 은주's pink.

## 7. Materials
Matte and slightly waxy, like clay or stop-motion puppets. Worn surfaces: chipped paint, scuffed floors, stained ceilings. No black outlines.

## 8. Gore
- Dark, glossy, exaggerated volume. Over-the-top enough to read as absurd, never clinical.
- **Appears wherever it fits:** noraebang fights, exploration traps, dangerous choices.
- **Scale:**
  - **½-heart hits** (mousetrap, 압정, rat bite, mop handle): a sharp burst of blood spray, a yelp, a bandage-worthy wound that stays visible for a while.
  - **1-heart hits** (live coal, broken bottle, statue's sword, imploding TV tube): a big splurge, a stagger, a lingering mark.
  - **Fight attacks and counters:** the full carnage set by each boss's song.
- Wounds can stay on 보람's model until healed (🟡 decals that clear when hearts are restored).

## 9. Technical
- **Live 3D** in Godot 4.7.2, **Forward+** renderer, PC, **1920×1080**.
- Characters are rigged 3D models with shared animations (walk, idle, turn, climb, push, talk, react). Outfits swap on the same rig.
- Rooms are live 3D by default. **Pre-rendered backgrounds** may be used room by room where extra richness is needed, with live characters in front.
- Fog, haze and lighting done live in Godot. 🔍 Confirm which features need Forward+.
- The 640×360 pixel-art setup and the Galmuri pixel font are dropped. A new Korean font is chosen in a later session.
- Dialogue shows the live characters in the map, with close-ups for expressions. 🟡
- **HUD always on screen:** ❤️ hearts with halves, 👀 눈치, 🍡 DDEOK, 🔒 cards. Designed in Inkscape, laid out in Figma.

## 10. Style test deliverables
a. 보람 concept art (neutral + 2 expressions), from ComfyUI.
b. Classroom concept (blackboard, 조개탄 stove, TV), from ComfyUI.
c. 보람 as a 3D model, rigged, walking through a blocked-out 1979 classroom in Godot with the final lighting and fog.

## 11. Pipeline

| Tool | Job |
|---|---|
| ComfyUI | Concept art and character reference sheets |
| TRELLIS.2 (online: Hugging Face Space or Google Colab) | Approved concepts → 3D models |
| Blender | Clean-up, retopology, rigging, rooms, props |
| Mixamo or Blender | Base animations (🔍 Mixamo licence for files in an open-source repo — noted in the Hangul Hiking Trip log) |
| GIMP | Textures, paint-over, gore decals |
| Inkscape (+ user's inkscape-mcp) | UI, HUD, secret cards, title logo |
| Figma | Screen layouts |
| Godot | Lighting, fog, assembly, the game |
