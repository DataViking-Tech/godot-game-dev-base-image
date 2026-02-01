# Godot Game Development Image
# Extends ai-dev-base with game-specific tools

FROM ghcr.io/dataviking-tech/ai-dev-base:v2

# Build arguments for component versions
ARG GODOT_VERSION=4.5.1
ARG RENDER_BRIDGES_VERSION=main

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
    # Additional Godot libraries (t64 variants for Ubuntu 24.04)
    libfontconfig1 libasound2t64 libpulse0 \
    libxrender1 libxi6 libxkbcommon0 libxfixes3 \
    libxxf86vm1 libsm6 \
    # Multimedia tools
    ffmpeg \
    # Headless rendering
    xvfb \
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

# Install game-specific Python packages via uv (target Python 3.11 from base image)
RUN uv pip install --system --break-system-packages --python 3.11 pillow numpy pyyaml watchdog bpy

# Install render-bridges (GPU rendering bridge for Linux→Windows host)
RUN git clone --depth 1 --branch "${RENDER_BRIDGES_VERSION}" \
        https://github.com/DataViking-Tech/render-bridges.git /opt/render-bridges \
    && mkdir -p /workspace/temp/render-queue /workspace/temp/render-output \
    && chmod 777 /workspace/temp/render-queue /workspace/temp/render-output

# Make render-bridges importable as a Python module
ENV PYTHONPATH="/opt/render-bridges:${PYTHONPATH}"

# Create symlink for bun/node compatibility (if not in base)
RUN if [ ! -L /usr/local/bin/node ]; then \
        ln -s /usr/local/bin/bun /usr/local/bin/node 2>/dev/null || true; \
    fi

# Append godot-specific utility docs to the base image documentation
COPY docs/UTILITIES.md /tmp/godot-utilities.md
RUN cat /tmp/godot-utilities.md >> /usr/local/share/image-docs/UTILITIES.md && rm /tmp/godot-utilities.md

# Copy and run validation script to catch tool access issues at build time
COPY tests/validate-tools.sh /usr/local/bin/validate-tools.sh
RUN chmod +x /usr/local/bin/validate-tools.sh

# Validate tools as vscode user (catches permission issues before runtime)
USER vscode
RUN /usr/local/bin/validate-tools.sh
USER root

# Set working directory
WORKDIR /workspace

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD godot --version && python3 --version || exit 1

# Default shell
CMD ["/bin/bash"]

# Switch user back before exiting
USER vscode
