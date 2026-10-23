# Noraebang Night — Style Brief

*Version 0.1 · Approved 23 October 2026*
*Applies to: Act 1 style test, then the whole game unless a later version replaces it.*

> Production document. Changes are made by issuing a new version (v0.2…); this file stays unchanged.

---

## 1. One-line look
A realistic cartoon diorama of 1979 Korea, lit like a nightmare. Familiar places, slightly wrong. Reference for mood and proportion: *Little Nightmares*.

## 2. Proportions — the core idea
- **Children:** small, big heads (~4 heads tall), readable faces.
- **Adults:** oversized and looming. Heavy, doughy or stretched; faces a little too big, hands a little too large.
- The camera never lets 보람 feel big.

## 3. 보람 — design rules
- 7 years old. Curly dark hair, warm brown skin, expressive eyes.
- The grotesque exaggeration applies to her tormentors, **never to her ethnic features**. She is drawn with care; the adults are the monsters.
- 1979 school clothes: knitted vest, white collar, 명찰 name tag, red 책가방.

## 4. Camera
Fixed, side-on or slightly high, like looking into a dollhouse. Rooms framed as stage sets.

## 5. Lighting
One dominant light source per scene (window, fluorescent tube, TV glow, a single lamp). Deep shadows, haze or dust in the air. Adults' faces often half in shadow.

## 6. Palette — 1979, muted
- Cream walls, varnished wood, blackboard green, olive, mustard, cold TV grey. Low saturation.
- Accents, used sparingly: blood red, 태극기 red and blue, 은주's pink.

## 7. Materials
Matte and slightly waxy, like clay or stop-motion puppets. Worn surfaces: chipped paint, scuffed floors, stained ceilings. No black outlines.

## 8. Gore
Dark, glossy, exaggerated volume. Over-the-top enough to read as absurd, never clinical. Confined to noraebang fights.

## 9. Technical
- Renders at **1920×1080**.
- The game drops the 640×360 pixel-art setup and the pixel font; a new Korean font is chosen in a later session.
- Dialogue uses character renders with several expressions each.

## 10. Style test deliverables
a. 보람 concept portrait (neutral + 2 expressions)
b. Classroom corner concept (blackboard, stove, TV)
c. 보람 3D model rendered in that classroom with final lighting

## 11. Pipeline (Option B: 3D rendered into 2D)

| Tool | Job |
|---|---|
| ComfyUI | Concept art and character reference sheets |
| TRELLIS.2 (online: Hugging Face Space or Google Colab) | Approved concepts → 3D models |
| Blender | Clean-up, rooms, lighting, fog, rendering poses and expressions |
| GIMP | Paint-over: fixes, gore, grime, texture |
| Synfig | Optional small 2D animations from rendered layers |
| Inkscape (+ user's inkscape-mcp) | UI, HUD, secret cards, title logo |
| Figma | Screen layouts |
| Godot | Assembly |
