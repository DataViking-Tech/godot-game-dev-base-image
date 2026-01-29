# Godot Game Development Base Image

Custom devcontainer image with pre-installed game development tools for fast container startup.

## 🚀 Features

- **Godot 4.5.1** - Game engine with all dependencies
- **Python 3.11 + uv** - Package management
- **Bun** - Fast JavaScript runtime
- **Claude CLI** - AI coding assistant
- **beads** - Issue tracking CLI
- **System packages** - ffmpeg, build tools, multimedia libraries

## 📦 Usage

### In your devcontainer.json

```json
{
  "name": "My Game Project",
  "image": "ghcr.io/dataviking-tech/godot-game-dev-base-image:v1.0.0",

  "customizations": {
    "vscode": {
      "extensions": [
        "geequlim.godot-tools"
      ]
    }
  },

  "remoteEnv": {
    "EXPECTED_IMAGE_VERSION": "v1.0.0"
  },

  "postCreateCommand": "bash .devcontainer/postCreateCommand.sh"
}
```

### Minimal postCreateCommand.sh

```bash
#!/bin/bash
set -e

# Validate image version
ACTUAL_VERSION=$(cat /opt/image-version)
EXPECTED_VERSION="${EXPECTED_IMAGE_VERSION:-v1.0.0}"

if [ "$ACTUAL_VERSION" != "$EXPECTED_VERSION" ]; then
  echo "⚠️  WARNING: Image version mismatch"
fi

# Initialize git submodules
git submodule update --init --recursive

# Project-specific setup here

echo "✅ Container ready!"
```

## 🎯 Benefits

**Fast Startup:** 5-15 seconds (vs 3-5 minutes with runtime downloads)

**Consistent Environments:** Same image across all projects

**Disk Space Savings:** ~40% reduction vs per-project installations

## 🔄 Version Management

Check version:
```bash
cat /opt/image-version  # v1.0.0
```

Update to new version:
1. Edit `devcontainer.json` image tag
2. Rebuild: `Ctrl+Shift+P` → "Rebuild Container"

## 📚 Documentation

- [CHANGELOG](docs/CHANGELOG.md) - Version history
- [UPGRADING](docs/UPGRADING.md) - Migration guides
- [Testing](tests/) - Validation scripts

## 🏗️ Building Locally

```bash
docker build -t godot-dev:local .devcontainer/
docker run -it godot-dev:local bash
```

---

**Built with ❤️ by DataViking-Tech**