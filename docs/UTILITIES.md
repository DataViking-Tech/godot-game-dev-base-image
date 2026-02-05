
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
| `godot_render_bridge` | Godot SubViewport GPU rendering: `GodotRenderBridge`, `GodotRenderJob`, `GodotRenderResult` |

All modules are on `PYTHONPATH` automatically (`/opt/render-bridges`).

### Windows Watcher Scripts

| Script | Path | Description |
|--------|------|-------------|
| `render_watcher.ps1` | `/opt/render-bridges/scripts/windows/` | Monitors render-queue for Blender jobs, supports parallel processing |
| `godot_render_watcher.ps1` | `/opt/render-bridges/scripts/windows/` | Monitors godot-render-queue for Godot SubViewport jobs |

### Queue Directories

- Blender queue: `/workspace/temp/render-queue`
- Blender output: `/workspace/temp/render-output`
- Godot queue: `/workspace/temp/godot-render-queue`
- Godot output: `/workspace/temp/godot-render-output`

### Render Bridge Architecture

Three layers, each building on the previous:

| Layer | Module | Purpose |
|-------|--------|---------|
| Core | `render_bridge` | Generic Blender IPC — queue-based, works with any `.blend` file |
| Integration | `render_bridge_integration` | High-level Blender helpers — static previews, animation frames |
| Godot | `godot_render_bridge` | Godot scene rendering — biome showcases, single assets, animation capture |

The Blender layers (`render_bridge`, `render_bridge_integration`) handle `.blend` file rendering.
The Godot layer (`godot_render_bridge`) handles Godot SubViewport rendering with its own queue
and watcher. Both use the same host-delegation pattern: Linux writes a JSON job file, the Windows
watcher picks it up, renders with GPU access, and writes results back.

### Downstream Usage

All string parameters (`biome`, `camera`, `density`, `terrain_mode`, `render_mode`) accept
any value — define your game's vocabulary in your own project. Default values are sensible
starting points, not restrictions.

```python
from godot_render_bridge import GodotRenderBridge

bridge = GodotRenderBridge()

# Biome showcase with project-specific values
result = bridge.render_biome_showcase(
    biome='my_custom_biome',
    camera='overhead',
    density='dense'
)

# Single asset render
result = bridge.render_single_asset(
    asset_path='res://assets/blender/props/my_prop.glb',
    biome='desert',
    terrain_mode='procedural'
)

# Async: submit without waiting
job_id = bridge.submit_biome_showcase(biome='forest', camera='wide')
# ... do other work ...
result = bridge.wait_for_result(job_id)
```

`PYTHONPATH=/opt/render-bridges` is set automatically, making the module available
without additional configuration.

## Claude Code Agent Configs (`/opt/agent-configs`)

Pre-built Claude Code agent definitions for game development workflows.
Source embedded from `lib/agent-configs/` at build time.

### Available Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `3d-model-reviewer` | opus | Reviews Blender models, GLB exports, and animation setups for mesh quality, rigging, and visual polish |
| `technical-director` | sonnet | Architectural guidance, performance optimization, stability analysis for Godot 4 projects |
| `art-director` | sonnet | Creative review and feedback on visual aspects — characters, environments, UI aesthetics |
| `creative-director` | sonnet | Game vision, tone, core pillars (combat/story/player freedom), cross-discipline consistency |
| `gamer-appeal-critic` | sonnet | Honest player-perspective assessment from an experienced RTS/FPS/TD gamer |
| `general-gamer-reviewer` | sonnet | Broad mainstream gamer perspective on player-facing features and UX |
| `marketing-director` | sonnet | Consumer-focused evaluation, audience sentiment, campaign strategy |
| `ui-hud-design-reviewer` | sonnet | HUD design, menu flow, information hierarchy, cognitive load assessment |

### Installation into Downstream Projects

The install script copies agents into your project's `.claude/agents/` directory,
skipping any that already exist (so downstream projects can override individual agents).

Add to your `devcontainer.json` `postCreateCommand`:

```bash
/opt/agent-configs/install-agents.sh
```

Or run manually:

```bash
/opt/agent-configs/install-agents.sh
```

### Customization

To override a base-image agent, create your own version at `.claude/agents/<name>.md`
in your project. The install script will not overwrite existing files.

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
