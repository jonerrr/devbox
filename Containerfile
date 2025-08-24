FROM registry.fedoraproject.org/fedora-toolbox:42

LABEL com.github.containers.toolbox="true"

# get ready for installing
RUN dnf install -y dnf-plugins-core

# install vscode repo
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Add gemfury nushell repo
RUN echo "[gemfury-nushell]" > /etc/yum.repos.d/fury-nushell.repo && \
    echo "name=Gemfury Nushell Repo" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "baseurl=https://yum.fury.io/nushell/" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "gpgkey=https://yum.fury.io/nushell/gpg.key" >> /etc/yum.repos.d/fury-nushell.repo

# add scc copr
# RUN dnf copr enable lihaohong/scc -y

# add k9s copr
# RUN dnf copr enable luminoso/k9s -y

# add mise and gh repos
RUN curl https://mise.jdx.dev/rpm/mise.repo > /etc/yum.repos.d/mise.repo
RUN curl https://cli.github.com/packages/rpm/gh-cli.repo > /etc/yum.repos.d/gh-cli.repo

RUN dnf update -y && \
    dnf install -y \
    git \
    age \
    btop \
    GraphicsMagick \
    clang \
    clang-tools-extra \
    cmake \
    golang \
    gh \
    jq \
    fira-code-fonts \
    neovim \
    nushell \
    tldr \
    tilp2 \
    nss-tools \
    unzip \
    zip \
    p7zip \
    helm \
    kubernetes-client \
    k9s \
    libXrandr-devel \
    libXinerama-devel \
    libXcursor-devel \
    libX11-devel \
    libXi-devel \
    vulkan-devel \
    vulkan-tools \
    glslc \
    libshaderc-devel \
    mesa-libGL-devel \
    mold \
    podman-compose \
    postgresql \
    rustup \
    code \
    xclip \
    openssl-devel \
    mise \
    wget \
    skopeo \
    sqlite-devel \
    gcc \
    gcc-c++ \
    vips-tools \
    zlib-devel \
    @development-tools

# install cosign
# RUN dnf install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")-1.x86_64.rpm

# install flux cli
# RUN curl -s https://fluxcd.io/install.sh | bash

# Install sops
# RUN curl -s https://api.github.com/repos/getsops/sops/releases/latest \
#     | grep "browser_download_url.*.x86_64.rpm" \
#     | cut -d : -f 2,3 \
#     | tr -d \" \
#     | wget -qi -
# RUN rpm -i sops*.rpm

# install bitwarden cli
# RUN curl -L "https://vault.bitwarden.com/download/?app=cli&platform=linux" -o bw.zip && \
#     unzip bw.zip -d /usr/local/bin && \
#     chmod +x /usr/local/bin/bw && \
#     rm bw.zip

# install chezmoi
# RUN sh -c "$(curl -fsLS get.chezmoi.io)"

# install cilium
# RUN CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt) && \
#     CLI_ARCH=amd64 && \
#     if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi && \
#     curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum} && \
#     sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum && \
#     sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin && \
#     rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

RUN dnf clean all

# link tools
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman-compose && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
    ln -s /usr/bin/distrobox-host-exec /usr/bin/restic && \
    ln -s /usr/bin/distrobox-host-exec /usr/bin/rclone && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/resticprofile && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open

# COPY finish-setup /usr/local/bin/finish-setup
# RUN chmod +x /usr/local/bin/finish-setup
