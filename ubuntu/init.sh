#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
ROOT=$(dirname $DIR)
cd $DIR
set -ex
export DEBIAN_FRONTEND=noninteractive

CURL="curl --connect-timeout 5 --max-time 10 --retry 99 --retry-delay 0"

if ! curl --connect-timeout 2 -m 4 -s https://t.co >/dev/null; then
  CN=1
  git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com"
  cd /etc/apt
  sed -i "s/archive.ubuntu.com/mirrors.163.com/g" /etc/apt/sources.list
  export GOPROXY=https://goproxy.cn,direct
  export ZHOS=$ROOT/build/ubuntu_zh/os
  rsync -avI $ZHOS/ /
  source $ZHOS/root/.export
fi

export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export LANGUAGE=zh_CN.UTF-8
export TZ=Asia/Shanghai

cd ~

apt-get update &&
  apt-get install -y tzdata language-pack-zh-hans zram-config

sd '^echo \$mem' 'echo zstd > /sys/block/zram0/comp_algorithm ; echo $$mem' /usr/bin/init-zram-swapping
systemctl enable --now zram-config

sysctl_conf=/etc/sysctl.conf

sysctl_set() {
  if ! grep -q "vm.$1" "$sysctl_conf"; then
    echo -e "\nvm.$1=$2\n" >>$sysctl_conf
  fi
  sysctl vm.$1=$2
}

sysctl_set page-cluster 0
sysctl_set extfrag_threshold 0
sysctl_set swappiness 100

sed -i '/^[[:space:]]*$/d' $sysctl_conf

ln -snf /usr/share/zoneinfo/$TZ /etc/localtime &&
  echo $TZ >/etc/timezone &&
  locale-gen zh_CN.UTF-8

export DEBIAN=_FRONTEND noninteractive
export TERM=xterm-256color

apt-get update &&
  apt-get upgrade -y &&
  apt-get dist-upgrade -y &&
  apt-get install -y unzip gcc build-essential musl-tools g++ git bat \
    libffi-dev zlib1g-dev liblzma-dev libssl-dev pkg-config \
    libreadline-dev libbz2-dev libsqlite3-dev \
    libzstd-dev protobuf-compiler zsh \
    software-properties-common curl wget cmake \
    autoconf automake libtool
chsh -s /bin/zsh root

apt-get install -y fd-find exa ncdu exuberant-ctags asciinema man \
  tzdata sudo tmux openssh-client libpq-dev \
  rsync mlocate gist less util-linux apt-utils socat \
  htop cron postgresql-client bsdmainutils \
  direnv iputils-ping dstat zstd pixz jq git-extras \
  aptitude clang-format p7zip-full openssh-server

export ASDF_DIR=/opt/asdf
export ASDF_DATA_DIR=/opt/asdf

if [ ! -d "$ASDF_DIR" ]; then
  git clone --depth=1 https://github.com/asdf-vm/asdf.git /opt/asdf
fi

cd /opt/asdf

. /opt/asdf/asdf.sh

asdf plugin add python https://github.com/asdf-community/asdf-python.git || true
asdf install python latest &

asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git || true
asdf install lua latest &

asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true
asdf install nodejs latest &

asdf plugin-add golang https://github.com/kennyp/asdf-golang.git || true
asdf install golang latest &

if ! [ -x "$(command -v mosh)" ]; then
  git clone --depth=1 https://github.com/mobile-shell/mosh.git &&
    cd mosh && ./autogen.sh && ./configure &&
    make && make install && cd .. && rm -rf mosh
fi

export CARGO_HOME=/opt/rust
export RUSTUP_HOME=/opt/rust

$CURL https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path

source $CARGO_HOME/env

cargo install --root /usr/local --git https://github.com/user-tax-dev/ripgrep.git &

cargo install --root /usr/local \
  stylua cargo-cache sd tokei \
  diskus watchexec-cli cargo-edit cargo-update &

wait || {
  echo "error : $?" >&2
  exit 1
}

cd $CARGO_HOME

rm -rf config
mkdir -p ~/.cargo
touch ~/.cargo/config
ln -s ~/.cargo/config .

# 官方的neovim没编译python，所以用neovim-ppa/unstable

add-apt-repository -y ppa:neovim-ppa/unstable &&
  apt-get update &&
  apt-get install -y neovim

if ! [ -x "$(command -v czmod)" ]; then
  git clone --depth=1 https://github.com/skywind3000/czmod.git && cd czmod && ./build.sh && mv czmod /usr/local/bin && cd .. && rm -rf czmod
fi

export BUN_INSTALL=/opt/bun

if [ ! -d "$BUN_INSTALL" ]; then
  [ $CN ] && export GITHUB=https://ghproxy.com/https://github.com
  $CURL https://ghproxy.com/https://raw.githubusercontent.com/oven-sh/bun/main/src/cli/install.sh | bash
#$CURL https://bun.sh/install | bash
fi

wait || {
  echo "error : $?" >&2
  exit 1
}

asdf global python latest
asdf global nodejs latest
asdf global lua latest
asdf global golang latest

npm install -g yarn pnpm

asdf reshim

yarn global add neovim npm-check-updates coffeescript node-pre-gyp \
  diff-so-fancy rome@next @antfu/ni prettier \
  @prettier/plugin-pug stylus-supremacy &

go install mvdan.cc/sh/cmd/shfmt@latest &
go install github.com/muesli/duf@master &
go install github.com/louisun/heyspace@latest &

wait || {
  echo "error : $?" >&2
  exit 1
}
asdf reshim

ln -s /usr/bin/gist-paste /usr/bin/gist &&
  cd /usr/local &&
  wget https://cdn.jsdelivr.net/gh/junegunn/fzf/install -O fzf.install.sh &&
  bash ./fzf.install.sh && rm ./fzf.install.sh && cd ~ &&
  echo 'PATH=/opt/rust/bin:$PATH' >>/etc/profile.d/path.sh

rsync -avI $ROOT/os/root/ /root
declare -A ZINIT
ZINIT_HOME=/opt/zinit/zinit.git
ZINIT[HOME_DIR]=/opt/zinit
ZPFX=/opt/zinit/polaris
mkdir -p /opt/zinit && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME || true

cat /root/.zinit.zsh | grep --invert-match "^zinit ice" | zsh &&
  /opt/zinit/plugins/romkatv---powerlevel10k/gitstatus/install
rsync -avI $ROOT/os/usr/share/nvim/ /usr/share/nvim
rsync -avI $ROOT/os/etc/vim/ /etc/vim

update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 1 &&
  update-alternatives --set vi /usr/bin/nvim &&
  update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 1 &&
  update-alternatives --set vim /usr/bin/nvim

update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 1 &&
  update-alternatives --set editor /usr/bin/nvim

$CURL -fLo /etc/vim/plug.vim --create-dirs https://cdn.jsdelivr.net/gh/junegunn/vim-plug/plug.vim &&
  vi -E -s -u /etc/vim/sysinit.vim +PlugInstall +qa &&
  vi +'CocInstall -sync coc-json coc-yaml coc-css coc-python coc-vetur coc-tabnine coc-svelte' +qa
find /etc/vim -type d -exec chmod 755 {} +

pip install --upgrade pip glances pylint supervisor python-language-server ipython xonsh pynvim yapf flake8 &&
  asdf reshim

ldconfig

ssh_ed25519=/root/.ssh/id_ed25519
if [ ! -f "$ssh_ed25519" ]; then
  ssh-keygen -t ed25519 -P "" -f $ssh_ed25519
fi

cd /
rsync -avI $ROOT/os/ /

# 对时服务
apt install -y systemd-timesyncd

cat >/etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=ntp.tencent.com ntp.aliyun.com ntp.ubuntu.com time.google.com time.windows.com ntp.ntsc.ac.cn
EOF

# 内存小于1GB不装 docker
mesize=$(cat /proc/meminfo | grep -oP '^MemTotal:\s+\K\d+' /proc/meminfo)
[ $mesize -gt 999999 ] && $DIR/init-docker.sh

sd -s "#cron.*" "cron.*" /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog

timedatectl set-ntp true
systemctl enable --now systemd-timesyncd

ipinfo=$(curl -s ipinfo.io)

iporg=$(echo $ipinfo | jq -r ".org")

ip=$(echo $ipinfo | jq -r '.ip' | sed 's/\./-/g')

case $iporg in
*"Tencent"*) iporg=qq ;;
*"Contabo"*) iporg=con ;;
*"Alibaba"*) iporg=ali ;;
*"Amazon"*) iporg=aws ;;
*) iporg=unknown ;;
esac

ipaddr=$(echo $ipinfo | jq -r '.city' | dd conv=lcase 2>/dev/null | sed 's/\s//g')

cpu=$(cat /proc/cpuinfo | grep "processor" | wc -l)

name=$iporg-$ipaddr-$ip

echo $name

hostnamectl set-hostname $name

apt-get autoremove -y

rm -rf /root/.cache/pip &&
  python -m pip cache purge &&
  go clean --cache &&
  yarn cache clean --mirror &&
  npm cache clean -f &&
  apt-get clean -y

rm -rf $CARGO_HOME/registry &&
  cargo-cache --remove-dir git-repos,registry-sources &&
  cargo-cache -e

[ $CN ] &&
  git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com" &&
  rsync -avI $ZHOS/ /

sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config
service sshd reload
apt autoremove -y
echo '👌 ✅'
