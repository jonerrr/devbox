FROM quay.io/fedora/fedora:39 

LABEL com.github.containers.toolbox="true"

RUN dnf install -y dnf-plugins-core

RUN cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

RUN sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

RUN dnf copr enable atim/nushell -y

RUN dnf config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo

RUN dnf update -y && \
    dnf install -y \
    git \
    age \
    jq \
    neovim \
    tldr \
    nss-tools \
    unzip \
    zip \
    p7zip \
    helm \
    kubectl \
    nushell \
    podman-compose \
    rust \
    cargo \
    code \
    xclip \
    openssl-devel \
    mise \
    wget \
    skopeo

RUN dnf clean all

RUN KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-) && \
    wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal && \
    install -m 755 kubeseal /usr/local/bin/kubeseal

RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && \
    chmod +x mkcert-v*-linux-amd64 && \
    cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

RUN curl -JLO "https://github.com/derailed/k9s/releases/download/v0.31.9/k9s_Darwin_amd64.tar.gz" && \
    tar -xzf k9s_Darwin_amd64.tar.gz && \
    chmod +x k9s && \
    cp k9s /usr/local/bin/k9s

RUN dnf install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")-1.x86_64.rpm

RUN curl -s https://fluxcd.io/install.sh | bash

RUN sh -c "$(curl -fsLS get.chezmoi.io)"

RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
    ln -fs /usr/bin/distrobox-host-exec /usr/bin/restic && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/resticprofile && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open

COPY finish-setup /usr/local/bin/finish-setup
RUN chmod +x /usr/local/bin/finish-setup
