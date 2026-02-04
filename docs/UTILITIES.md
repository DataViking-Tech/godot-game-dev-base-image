
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
Source embedded from `lib/render-bridges/` at build time.

### Python Modules

| Module | Description |
|--------|-------------|
| `render_bridge` | Core package: `RenderBridge`, `RenderJob`, `RenderResult` for Blender GPU rendering |
| `render_bridge_integration` | High-level helpers: `render_static_preview_gpu()`, `render_animation_frames_gpu()`, `is_bridge_available()` |

All modules are on `PYTHONPATH` automatically (`/opt/render-bridges`).

### Windows Watcher Scripts

| Script | Path | Description |
|--------|------|-------------|
| `render_watcher.ps1` | `/opt/render-bridges/scripts/windows/` | Monitors render-queue for Blender jobs, supports parallel processing |

### Queue Directories

- Blender queue: `/workspace/temp/render-queue`
- Blender output: `/workspace/temp/render-output`

## Godot LSP Auto-Start

The image includes an automatic LSP server startup script that runs via `postStartCommand`.
When a container starts, it detects the Godot project and launches the LSP server in the
background for IDE code completion and diagnostics.

| Setting | Default | Description |
|---------|---------|-------------|
| `GODOT_PROJECT_PATH` | *(auto-detect)* | Explicit path to directory containing `project.godot` |
| `GODOT_LSP_PORT` | `6005` | LSP server port |
| `GODOT_LSP_DISABLED` | `0` | Set to `1` to skip auto-start |

**Auto-detection order:**
1. `GODOT_PROJECT_PATH` env var (if set)
2. `project.godot` in workspace root
3. Recursive search (max depth 3) from workspace root

**Manual usage:** `/usr/local/bin/godot-lsp-start`

**Logs:** `/tmp/godot-lsp.log`

## Additional System Libraries

Godot runtime dependencies pre-installed:

- X11, XCursor, XInput, XRandR, XRender, XFixes, Xinerama
- OpenGL / EGL / GLES2
- Fontconfig, ALSA, PulseAudio
- XKBCommon, Xxf86vm, SM/ICE
