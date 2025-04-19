FROM registry.fedoraproject.org/fedora-toolbox:42

LABEL com.github.containers.toolbox="true"

# get ready for installing
RUN dnf install -y dnf-plugins-core

# install conda repos
# RUN rpm --import https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc
# RUN cat <<EOF | tee /etc/yum.repos.d/conda.repo
# [conda]
# name=Conda
# baseurl=https://repo.anaconda.com/pkgs/misc/rpmrepo/conda
# enabled=1
# gpgcheck=1
# gpgkey=https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc
# EOF

# install vscode repo
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# install infisical repo
# RUN curl -1sLf \
#     'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.rpm.sh' \
#     | bash

# add nushell copr
# RUN dnf copr enable atim/nushell -y
# add scc copr
RUN dnf copr enable lihaohong/scc -y
# add k9s copr
RUN dnf copr enable luminoso/k9s -y

# add mise repo
# RUN dnf config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo

# RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

RUN curl https://mise.jdx.dev/rpm/mise.repo > /etc/yum.repos.d/mise.repo
RUN curl https://cli.github.com/packages/rpm/gh-cli.repo > /etc/yum.repos.d/gh-cli.repo

RUN dnf update -y && \
    dnf install -y \
    git \
    age \
    # conda \
    GraphicsMagick \
    clang \
    clang-tools-extra \
    cmake \
    golang \
    gh \
    jq \
    java-21-openjdk \
    java-21-openjdk-devel \
    fira-code-fonts \
    neovim \
    tldr \
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
    protobuf-compiler \
    postgresql \
    rustup \
    code \
    xclip \
    openssl-devel \
    mise \
    wget \
    scc \
    skopeo \
    gcc \
    gcc-c++ \
    vips-tools \
    @development-tools

# install kubeseal
# RUN KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-) && \
#     wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" && \
#     tar -xzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal && \
#     install -m 755 kubeseal /usr/local/bin/kubeseal

# install mkcert
RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && \
    chmod +x mkcert-v*-linux-amd64 && \
    cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

# install cosign
RUN dnf install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")-1.x86_64.rpm

# install flux cli
RUN curl -s https://fluxcd.io/install.sh | bash

# install velero
# RUN curl -s https://api.github.com/repos/vmware-tanzu/velero/releases/latest \
#     | grep "browser_download_url.*linux-amd64.tar.gz" \
#     | cut -d : -f 2,3 \
#     | tr -d \" \
#     | wget -qi - -O velero.tar.gz
# RUN tar -xvf velero.tar.gz && \
#     install -m 755 velero*/velero /usr/local/bin/velero

# install nushell
RUN curl -s https://api.github.com/repos/nushell/nushell/releases/latest \
    | grep "browser_download_url.*aarch64-unknown-linux-gnu.tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi - -O nu.tar.gz
RUN tar -xvf nu.tar.gz && \
    install -m 755 nu*/nu /usr/local/bin/nu

# Install sops
RUN curl -s https://api.github.com/repos/getsops/sops/releases/latest \
    | grep "browser_download_url.*.x86_64.rpm" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -
RUN rpm -i sops*.rpm

# install bitwarden cli
RUN curl -L "https://vault.bitwarden.com/download/?app=cli&platform=linux" -o bw.zip && \
    unzip bw.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/bw && \
    rm bw.zip

# install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)"

# install cilium
RUN CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt) && \
    CLI_ARCH=amd64 && \
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi && \
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum} && \
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum && \
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin && \
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

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

COPY finish-setup /usr/local/bin/finish-setup
RUN chmod +x /usr/local/bin/finish-setup
