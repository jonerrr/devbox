(yay -S --noconfirm \
    fluxcd \
    cloudflared-bin \
    chezmoi \
    fluxcd \
    helm \
    k9s \
    kubectl-bin \
    kubeseal \
    mise-bin \
    mkcert \
    neovim \
    nushell \
    p7zip \
    tldr \
    unzip \
    visual-studio-code-bin \
    xclip \
    zip)

distrobox-export --app code

do {
  let misepath = ($nu.config-path | path dirname | path join "mise.nu")
  run-external mise activate nu --redirect-stdout | save $misepath -f
  $"\nsource "($misepath)"" | save $nu.config-path --append
}