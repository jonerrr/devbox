FROM registry.fedoraproject.org/fedora-toolbox:39 

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

RUN curl -1sLf \
    'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.rpm.sh' \
    | sudo -E bash


RUN dnf copr enable atim/nushell -y

RUN sudo rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-fedora-repo-2-1.noarch.rpm

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
    python3 \
    python3-pip \
    rustup \
    code \
    xclip \
    openssl-devel \
    mise \
    wget \
    skopeo \
    gcc \
    gcc-c++ \ 
    pgadmin4 

RUN dnf clean all

RUN KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-) && \
    wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal && \
    install -m 755 kubeseal /usr/local/bin/kubeseal

RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && \
    chmod +x mkcert-v*-linux-amd64 && \
    cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

RUN dnf install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")-1.x86_64.rpm

RUN curl -s https://fluxcd.io/install.sh | bash

RUN curl -s https://api.github.com/repos/vmware-tanzu/velero/releases/latest \
    | grep "browser_download_url.*linux-amd64.tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi - -O velero.tar.gz
RUN tar -xvf velero.tar.gz && \
    install -m 755 velero*/velero /usr/local/bin/velero

RUN sh -c "$(curl -fsLS get.chezmoi.io)"

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
