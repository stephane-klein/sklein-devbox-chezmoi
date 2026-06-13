FROM fedora:43

# Note: Chezmoi and starship are installed via dnf rather than Mise because they are
# primary components needed early in the ssh-forcecommand-entrypoint.sh initialization script.
# Initially they were installed via Mise, but this caused circular dependency issues
# and problems in .zshrc.
# Another point: I know that mise evolves frequently and we accept rebuilding the Docker
# image when Mise is updated -- this is an intentional tradeoff for now. This decision
# may be revisited in the future.
#
# gcc package for Neovim Treesitter support
RUN dnf copr enable -y atim/starship && \
    dnf copr enable -y jdxcode/mise && \
    dnf copr enable -ytkbcopr/oils-for-unix && \
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
        gcc \
        unzip \
        libnotify \
        pulseaudio-utils \
        libatomic \
        gcc-c++ \
        python3 \
        make \
        htop \
        psmisc \
        sqlite \
        podman \
        podman-compose \
        podman-docker \
        rsync \
        pwgen \
        oils-for-unix \
        openssl \
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
# RUN curl -sSL "https://github.com/gopasspw/gopass/releases/download/v${GOPASS_VERSION}/gopass-${GOPASS_VERSION}-linux-amd64.tar.gz" \
# I use this fork to get this patch: https://github.com/gopasspw/gopass/pull/3364/
RUN curl -sSL "https://github.com/stephane-klein/gopass/releases/download/1.16.2-sklein/gopass-1.16.2-sklein-linux-amd64.tar.gz" \
        -o /tmp/gopass.tar.gz && \
    tar -xzf /tmp/gopass.tar.gz -C /tmp && \
    mv /tmp/gopass /usr/local/bin/gopass && \
    rm -rf /tmp/gopass*

# Install pebble
ARG PEBBLE_VERSION=1.30.1
RUN curl -sSL "https://github.com/canonical/pebble/releases/download/v${PEBBLE_VERSION}/pebble_v${PEBBLE_VERSION}_linux_amd64.tar.gz" \
        -o /tmp/pebble.tar.gz && \
    tar -xzf /tmp/pebble.tar.gz -C /tmp && \
    mv /tmp/pebble /usr/local/bin/pebble && \
    rm -rf /tmp/pebble*

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

# Copy pebble init scripts
COPY entrypoint-init.d/ /etc/entrypoint-init.d/
RUN chmod +x /etc/entrypoint-init.d/*

# Setup pebble directory with open permissions for rootless keep-id
RUN mkdir -p /var/lib/pebble && chmod 777 /var/lib/pebble

# Copy pebble layers
COPY pebble/layers/ /var/lib/pebble/layers/

# Copy container entrypoint script
COPY container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
RUN chmod +x /usr/local/bin/container-entrypoint.sh

# Copy init script
COPY sklein-devbox-init.sh /usr/local/bin/sklein-devbox-init.sh
RUN chmod +x /usr/local/bin/sklein-devbox-init.sh

# Copy SSH ForceCommand entrypoint script
COPY ssh-forcecommand-entrypoint.sh /usr/local/bin/ssh-forcecommand-entrypoint.sh
RUN chmod +x /usr/local/bin/ssh-forcecommand-entrypoint.sh

# Configure Pebble directory
ENV PEBBLE=/var/lib/pebble
RUN echo 'export PEBBLE=/var/lib/pebble' > /etc/profile.d/pebble.sh

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

ENTRYPOINT ["/usr/local/bin/container-entrypoint.sh"]
