# Godot Game Development Base Image
# Pre-installed tools for fast devcontainer startup

FROM ubuntu:22.04

# Metadata
LABEL org.opencontainers.image.source=https://github.com/DataViking-Tech/godot-game-dev-base-image
LABEL org.opencontainers.image.description="Game dev environment: Godot 4.5.1, Python 3.11, Bun, Claude CLI, beads"
LABEL maintainer="DataViking-Tech"

# Build arguments
ARG GODOT_VERSION=4.5.1
ARG PYTHON_VERSION=3.11
ARG BUN_VERSION=1.1.38
ARG IMAGE_VERSION=v1.0.0

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV GODOT_VERSION=${GODOT_VERSION}
ENV PYTHON_VERSION=${PYTHON_VERSION}

# System packages (single layer to minimize size)
RUN apt-get update && apt-get install -y \
    # Core tools
    git curl wget unzip ca-certificates \
    # Godot dependencies
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libgl1 \
    libegl1 libgles2 libglx0 \
    # Multimedia
    ffmpeg \
    # Additional libraries from frontline-forge requirements
    libfontconfig1 libasound2 libpulse0 \
    libxrender1 libxi6 libxkbcommon0 libxfixes3 \
    libxxf86vm1 libsm6 \
    # Build tools
    build-essential \
    # Utilities
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Godot (pre-downloaded for fast startup)
RUN echo "Installing Godot ${GODOT_VERSION}..." \
    && wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && unzip -q "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -d /opt \
    && mv "/opt/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /opt/godot \
    && chmod +x /opt/godot \
    && ln -s /opt/godot /usr/local/bin/godot \
    && rm "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && godot --version

# Python (using system Python + uv for venv management)
RUN echo "Installing Python ${PYTHON_VERSION}..." \
    && apt-get update \
    && apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python3-pip \
    && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python3 \
    && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python \
    && rm -rf /var/lib/apt/lists/* \
    && python3 --version

# Create vscode user early (for user-specific tool installations)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to vscode user for user-specific installations
USER $USERNAME
WORKDIR /home/$USERNAME

# Install uv (Python package manager)
RUN echo "Installing uv..." \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

ENV PATH="/home/vscode/.cargo/bin:${PATH}"

# Install Bun
RUN echo "Installing Bun ${BUN_VERSION}..." \
    && curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}" \
    && echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc

ENV PATH="/home/vscode/.bun/bin:${PATH}"

# Create node symlink for bun compatibility
RUN ln -s /home/vscode/.bun/bin/bun /home/vscode/.bun/bin/node

# Install Claude CLI
RUN echo "Installing Claude CLI..." \
    && curl -fsSL https://claude.ai/install.sh | bash \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

ENV PATH="/home/vscode/.local/bin:${PATH}"

# Install Node.js and npm (needed for beads postinstall scripts)
USER root
RUN echo "Installing Node.js for beads..." \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME

# Install beads (using npm for reliable postinstall script execution)
RUN echo "Installing beads..." \
    && npm install -g @beads/bd

# Write version file for validation
USER root
RUN echo "${IMAGE_VERSION}" > /opt/image-version \
    && echo "Godot: ${GODOT_VERSION}" >> /opt/image-manifest \
    && echo "Python: ${PYTHON_VERSION}" >> /opt/image-manifest \
    && echo "Bun: ${BUN_VERSION}" >> /opt/image-manifest \
    && echo "Image: ${IMAGE_VERSION}" >> /opt/image-manifest

# Back to vscode user
USER $USERNAME
WORKDIR /workspace

# Validate installations
RUN echo "Validating tool installations..." \
    && godot --version \
    && python3 --version \
    && uv --version \
    && bun --version \
    && claude --version || echo "Claude CLI installed (may need auth)" \
    && bd --version \
    && echo "All tools validated successfully!"

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD godot --version && python3 --version || exit 1
