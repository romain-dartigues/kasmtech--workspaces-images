ARG BASE_IMAGE="docker.io/kasmweb/ubuntu-noble-desktop:develop"
FROM $BASE_IMAGE

USER root

# cleanup
RUN apt update \
 && apt purge -y \
    bluez\* \
    code \
    cups\* \
    evolution\* \
    firefox \
    gamepadtool \
    gnome-bluetooth\* \
    idle-python\* \
    joystick \
    jstest-gtk \
    nextcloud\* \
    pocketsphinx\* \
    remmina\* \
    sane\* \
    signal-desktop \
    slack-desktop \
    sublime-text \
    thunderbird \
    vlc\* \
    whoopsie\* \
    xul-ext-ubufox \
    zoom \
 && dpkg -l | awk '/language-pack/ && !/language-pack-en/{print $2}' | xargs -r apt purge -y \
 && apt autoremove -y \
 && apt install -y \
    localepurge \
 && >/etc/default/locale printf '%s\n' \
    LANG=C.UTF-8 \
    LC_ADDRESS=fr_FR.utf8 \
    LC_MONETARY=fr_FR.utf8 \
    LC_NAME=fr_FR.utf8 \
    LC_PAPER=fr_FR.utf8 \
    LC_TIME=en_DK.utf8 \
 && . /etc/default/locale \
 && locales=$(sed -n 's/.*=//p' /etc/default/locale | sort -u) \
 && sed 's/^USE_DPKG/#&/' -i /etc/locale.nopurge \
 && sed -r '/^#.*deleted/,${/^([^#]|$)/d}' -i /etc/locale.nopurge \
 && printf '%s\n' $locales >>/etc/locale.nopurge \
 && localepurge -v \
 && locale-gen --purge $locales \
 && rm -fr \
    /opt/Signal \
    /opt/Telegram \
    /opt/onlyoffice \
    /opt/sublime_text \
    /opt/zoom \
    /var/lib/apt/lists/*

RUN sed -i 's/^path-exclude.*man.*/#&/' /etc/dpkg/dpkg.cfg.d/excludes \
 && apt-get update \
 && pyver=$(apt-cache search 'python3\..*-full' | sed -r 's/python([^[:space:]]*)-full.*/\1/' | sort -Vr | head -1) \
 && apt-get install -y --no-install-recommends \
    bash-completion \
    binutils \
    fonts-noto \
    fonts-terminus \
    fonts-terminus-otb \
    gnupg2 \
    iputils-ping \
    lynx \
    man \
    manpages \
    mtr \
    net-tools \
    openssh-server \
    python${pyver}-full \
    software-properties-common \
    tmux \
    traceroute \
    tree \
    vim \
    xfonts-terminus \
    xfonts-terminus-dos \
    xfonts-terminus-oblique \
    zstd \
 && install -v /usr/bin/man.REAL /usr/bin/man \
 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${pyver} 2 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 2 \
 && for repo in \
    git-core/ppa \
    inkscape.dev/stable \
    mozillateam/ppa \
    phoerious/keepassxc \
    ;do add-apt-repository -ny "ppa:${repo}";done \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    alacritty \
    git \
    inkscape \
    keepassxc \
    mpv \
 && rm -rf /var/lib/apt/lists/*
# XXX: following repository does not work for this Ubuntu version:    jonathonf/vim \

ENV \
    PIP_DISABLE_PIP_VERSION_CHECK="yes" \
    PIP_NO_CACHE_DIR="no" \
    PIP_NO_WARN_SCRIPT_LOCATION="no" \
    PIP_NO_WARN_SCRIPT_LOCATION="no" \
    PIP_PROGRESS_BAR="off" \
    PIP_ROOT_USER_ACTION="ignore" \
    PIP_UPGRADE_STRATEGY="eager"

RUN wget -qO get-pip.py https://bootstrap.pypa.io/get-pip.py \
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
 && rm -rf "$temp" \
 && wget -nv -O- https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 |\
    install -v /dev/stdin /usr/bin/jq

EXPOSE 22
