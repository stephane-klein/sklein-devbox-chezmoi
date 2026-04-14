FROM fedora:43

# Note: Chezmoi and starship are installed via dnf rather than Mise because they are
# primary components needed early in the entrypoint.sh initialization script.
# Initially they were installed via Mise, but this caused circular dependency issues
# and problems in .zshrc.
# Another point: I know that mise evolves frequently and we accept rebuilding the Docker
# image when Mise is updated -- this is an intentional tradeoff for now. This decision
# may be revisited in the future.
RUN dnf copr enable -y atim/starship && \
    dnf copr enable -y jdxcode/mise && \
    dnf update -y && \
    dnf install -y \
        procps-ng \
        util-linux \
        coreutils \
        findutils \
        diffutils \
        which \
        file \
        tree \
        curl \
        git \
        wget \
        zsh \
        chezmoi \
        mise \
        starship \
        sudo \
        pinentry-tty \
        gum \
        fzf \
        openssh-server \
        && \
    dnf clean all

# Install age
ARG AGE_VERSION=1.3.1
RUN curl -sSL "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz" \
        -o /tmp/age.tar.gz && \
    tar -xzf /tmp/age.tar.gz -C /tmp && \
    mv /tmp/age/age /usr/local/bin/age && \
    mv /tmp/age/age-keygen /usr/local/bin/age-keygen && \
    mv /tmp/age/age-inspect /usr/local/bin/age-inspect && \
    rm -rf /tmp/age*

# Install gopass
ARG GOPASS_VERSION=1.16.1
RUN curl -sSL "https://github.com/gopasspw/gopass/releases/download/v${GOPASS_VERSION}/gopass-${GOPASS_VERSION}-linux-amd64.tar.gz" \
        -o /tmp/gopass.tar.gz && \
    tar -xzf /tmp/gopass.tar.gz -C /tmp && \
    mv /tmp/gopass /usr/local/bin/gopass && \
    rm -rf /tmp/gopass*

# Install s6-overlay
RUN curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.2.0/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.2.0/s6-overlay-x86_64.tar.xz -o /tmp/s6-overlay-x86_64.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm -f /tmp/s6-overlay-*.tar.xz

# Install neovim
ARG NEOVIM_VERSION=0.12.1
RUN curl -sSL "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
        -o /tmp/nvim.tar.gz && \
    tar -xzf /tmp/nvim.tar.gz -C /tmp && \
    cp -r /tmp/nvim-linux-x86_64/* /usr/local/ && \
    rm -rf /tmp/nvim*

# Create user sklein with fixed UID 1000
RUN groupadd -g 1000 sklein && \
    useradd -u 1000 -g sklein -s /bin/zsh -m sklein && \
    usermod -p '*' sklein

# Configure sudo for sklein user without password
RUN echo "sklein ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sklein && \
    chmod 440 /etc/sudoers.d/sklein

# Copy sshd config
COPY sshd_config /etc/ssh/sshd_config
RUN chmod 644 /etc/ssh/sshd_config

# Copy s6-overlay init scripts
COPY cont-init.d/ /etc/cont-init.d/
RUN chmod +x /etc/cont-init.d/*

# Copy s6-overlay services
COPY services.d/ /etc/services.d/
RUN find /etc/services.d/ -type f \( -name "run" -o -name "finish" \) -exec chmod +x {} \;

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Configure XDG directories
ENV XDG_CONFIG_HOME=/home/sklein/.config \
    XDG_DATA_HOME=/home/sklein/.local/share \
    XDG_CACHE_HOME=/home/sklein/.cache \
    XDG_STATE_HOME=/home/sklein/.local/state

# Create XDG directories (will be re-owned by entrypoint)
RUN mkdir -p ${XDG_CONFIG_HOME} ${XDG_DATA_HOME} ${XDG_CACHE_HOME} ${XDG_STATE_HOME}

# Set Zsh as default shell
ENV SHELL=/bin/zsh

WORKDIR /workspace/

ENTRYPOINT ["/init"]
