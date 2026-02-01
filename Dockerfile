# Godot Game Development Image
# Extends ai-dev-base with game-specific tools

FROM ghcr.io/dataviking-tech/ai-dev-base:v2.1.0

# Build arguments for component versions
ARG GODOT_VERSION=4.5.1

# Metadata
LABEL org.opencontainers.image.source=https://github.com/DataViking-Tech/godot-game-dev-base-image
LABEL org.opencontainers.image.description="Game dev environment: Godot ${GODOT_VERSION} + ai-dev-base tools"
LABEL maintainer="DataViking-Tech"

# Switch to root for system package installation
USER root

# Install Godot system dependencies
# (ai-dev-base provides: git, curl, wget, python3, build-essential)
RUN apt-get update && apt-get install -y \
    # Godot runtime dependencies
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libgl1 \
    libegl1 libgles2 libglx0 \
    # Additional Godot libraries
    libfontconfig1 libasound2 libpulse0 \
    libxrender1 libxi6 libxkbcommon0 libxfixes3 \
    libxxf86vm1 libsm6 \
    # Multimedia tools
    ffmpeg \
    # Utilities
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Godot
RUN echo "Installing Godot ${GODOT_VERSION}..." \
    && wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && unzip -q "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -d /opt \
    && mv "/opt/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /opt/godot \
    && chmod +x /opt/godot \
    && ln -s /opt/godot /usr/local/bin/godot \
    && rm "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && godot --version

# Install game-specific Python packages via uv
RUN uv pip install --system pillow numpy

# Create symlink for bun/node compatibility (if not in base)
RUN if [ ! -L /root/.bun/bin/node ]; then \
        ln -s /root/.bun/bin/bun /root/.bun/bin/node 2>/dev/null || true; \
    fi

# Set working directory
WORKDIR /workspace

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD godot --version && python3 --version || exit 1

# Default shell
CMD ["/bin/bash"]
