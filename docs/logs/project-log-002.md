# Project Log 002 — Art direction and toolchain

*23 October 2026 · Noraebang Night · Episode 1 · Act 1: 국민학교 시대*

> Read Project Log 001 first for the workflow rules and document map. This log adds to it.

---

## 0. New permanent workflow rule

6. **Nothing is done on the user's PC without explicit approval.** The chat may be linked to the user's Windows PC, but before every action there Claude states exactly what it will run and waits for a yes. Work is shared both ways: sometimes Claude operates the PC (with approval), sometimes the user runs tools from Claude's guides and prompts.

---

## 1. What happened this session

| Item | Result |
|---|---|
| Scene 00 video | `tests/capture.gd` now takes a tap-interval argument; recorded a 43 s playthrough with Godot's Movie Maker mode (`--write-movie`, 30 fps) and ffmpeg. Sent to the user. |
| User feedback on graphics | **Placeholder art rejected:** "far too vintage", heads and bodies read as single pixels. Lesson: Claude picked the look without asking. **Visual direction must be agreed before any visuals are made.** |
| Art direction | Decided: realistic cartoon, slightly strange and creepy, like *Little Nightmares*. |
| Production method | **Option B chosen: 3D rendered into 2D.** 3D characters and rooms made and lit in Blender, rendered as stills and short animations, placed in the 2D Godot game. Models stay reusable if the game ever moves to full 3D. |
| Style Brief v0.1 | Approved. `docs/design/noraebang-night-style-brief-v0.1.md`. |

---

## 2. User's hardware and installed tools

- **Main PC:** Windows 11, **Intel Arc B580 (12GB VRAM)**, 32GB RAM.
- **Laptop:** basic, CachyOS (fine for Godot, not for AI).
- **Installed:** ComfyUI, Blender, Inkscape (+ the user's own **inkscape-mcp**), Synfig Studio, GIMP, Figma.
- The Claude cloud workspace has **no GPU** (2 CPUs, 7GB RAM) and **cannot reach huggingface.co or download.blender.org**. AI generation and Blender work happen on the user's PC.

## 3. Toolchain findings

| Step | Tool | Runs on | Notes |
|---|---|---|---|
| Concept art | ComfyUI + SDXL-based model | B580 | ComfyUI supports Intel Arc. Intel ≠ CUDA: some tools need extra setup or won't run. Latest Intel drivers + Resizable BAR first. |
| Image → 3D | TRELLIS.2 (Microsoft, MIT) | **Not the B580** (needs NVIDIA, ~24GB VRAM recommended) | Use the free official Hugging Face Space or Google Colab. |
| 3D finishing and rendering | Blender | User's PC | Confirm Cycles on Intel Arc at install. |
| Music | ACE-Step 1.5 | B580 | Repo ships Intel XPU setup files; 12GB tier suggests the 2B DiT + smaller LM. |

**Licence notes**
- **Hunyuan3D is ruled out:** its licence does not apply in South Korea (also excludes EU and UK).
- FLUX.1 [dev] is non-commercial → avoid. FLUX.1 [schnell] is Apache 2.0. SDXL-based models allow commercial use. Check every model's licence before use.
- Blender MCP: possible once the PC is linked; not required (Blender can be scripted directly). Its page couldn't be fetched to confirm current features.

---

## 4. Open items

1. **Which ComfyUI models to install.** The user is deciding the wider AI toolchain in the **Hangul Hiking Trip** session first and will return. Check that session's logs (`claude/hht-project-log-*`, `hangul-hiking-trip-phase-0-project-log-*`) for shared tool decisions before proposing models.
2. Link this chat to the Windows PC from the Claude desktop app (user action).
3. Style test (brief §10): 보람 portrait, classroom corner, 보람 3D render. Each step needs approval.
4. Godot changes implied by brief §9 (1920×1080, drop pixel-art settings and pixel font) — not done yet; wait for the style test.
5. Still pending from Log 001: Scene 01 script, Systems Spec v0.2, the fight player, the 〈달님은 계란 후라이〉 track.
