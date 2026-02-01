
---

## Godot Engine

| Tool       | Description                                          |
|------------|------------------------------------------------------|
| `godot`    | Godot 4.5 — open-source game engine (headless CLI)  |
| `xvfb-run` | Virtual framebuffer for headless rendering          |
| `ffmpeg`   | Multimedia encoding, decoding, and streaming         |

## Game-Dev Python Packages

Installed system-wide via uv (Python 3.11):

| Package    | Description                                          |
|------------|------------------------------------------------------|
| `pillow`   | Image processing (sprites, textures, atlases)        |
| `numpy`    | Numerical computing (vectors, matrices, physics)     |
| `pyyaml`   | YAML parsing for config and data files               |
| `watchdog` | Filesystem event monitoring (hot-reload workflows)   |
| `bpy`      | Blender Python API (asset pipeline, batch exports)   |

## Render Bridges (`/opt/render-bridges`)

GPU rendering bridge for Linux-to-Windows host delegation.

- Added to `PYTHONPATH` automatically
- Queue directory: `/workspace/temp/render-queue`
- Output directory: `/workspace/temp/render-output`

## Additional System Libraries

Godot runtime dependencies pre-installed:

- X11, XCursor, XInput, XRandR, XRender, XFixes, Xinerama
- OpenGL / EGL / GLES2
- Fontconfig, ALSA, PulseAudio
- XKBCommon, Xxf86vm, SM/ICE
