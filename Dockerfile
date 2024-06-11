ARG BASE_IMAGE="kasmweb/desktop:1.15.0-rolling"
FROM $BASE_IMAGE

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bash-completion \
    binutils \
    fonts-noto \
    fonts-terminus \
    fonts-terminus-otb \
    gnupg2 \
    iputils-ping \
    mtr \
    net-tools \
    openssh-server \
    python3.9-full \
    software-properties-common \
    tmux \
    traceroute \
    tree \
    vim \
    xfonts-terminus \
    xfonts-terminus-dos \
    xfonts-terminus-oblique \
    zstd \
 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 2 \
 && for repo in \
    git-core/ppa \
    inkscape.dev/stable \
    jonathonf/vim \
    mozillateam/ppa \
    phoerious/keepassxc \
    ;do add-apt-repository -ny "ppa:${repo}";done \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    git \
    inkscape \
    keepassxc \
 && rm -rf /var/lib/apt/lists/*

RUN wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py \
 && python3 get-pip.py --break-system-packages \
 && python3 -m pip install --break-system-packages \
    PyYAML \
    yq \
 && rm -f get-pip.py

RUN temp=$(mktemp -d) \
 && cd "$temp" \
 && wget -nv \
    https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb \
    https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb \
    https://github.com/sharkdp/fd/releases/download/v10.1.0/fd-musl_10.1.0_amd64.deb \
 && dpkg -i *.deb \
 && rm -rf "$temp"

EXPOSE 22
