SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm-256color

# 不 passwd -d 这样没法ssh秘钥登录，每次都要输入密码
RUN apt-get update &&\
apt-get upgrade -y &&\
apt-get dist-upgrade -y &&\
apt-get install -y unzip build-essential musl-tools g++ git bat \
libffi-dev zlib1g-dev liblzma-dev libssl-dev pkg-config \
libreadline-dev libbz2-dev libsqlite3-dev \
libzstd-dev protobuf-compiler zsh \
software-properties-common curl wget cmake \
autoconf automake libtool &&\
passwd -d root && chsh -s /bin/zsh root

SHELL ["/bin/zsh", "-c"]

RUN git clone --depth=1 https://github.com/mobile-shell/mosh.git &&\
cd mosh && ./autogen.sh && ./configure &&\
make && make install && cd .. && rm -rf mosh

ENV CARGO_HOME /opt/rust
ENV RUSTUP_HOME /opt/rust

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --default-toolchain nightly
RUN \
source $CARGO_HOME/env &&\
cargo install --root /usr/local --git https://github.com/user-tax-dev/ripgrep.git &&\
cargo install --root /usr/local stylua cargo-cache sd tokei diskus watchexec-cli cargo-edit cargo-update &&\
rm -rf $CARGO_HOME/registry &&\
cargo-cache --remove-dir git-repos,registry-sources &&\
cargo-cache -e &&\
cd $CARGO_HOME &&\
ln -s ~/.cargo/config .

# 官方的neovim没编译python，所以用neovim-ppa/unstable
RUN \
  add-apt-repository -y ppa:neovim-ppa/unstable &&\
  apt-get update &&\
  apt-get install -y neovim

RUN git clone --depth=1 https://github.com/skywind3000/czmod.git && cd czmod && ./build.sh && mv czmod /usr/local/bin && cd .. && rm -rf czmod

ENV BUN_INSTALL /opt/bun
RUN curl https://bun.sh/install | bash

ENV ASDF_DIR /opt/asdf
ENV ASDF_DATA_DIR /opt/asdf
# todo python 3.10.6 - latest
RUN \
git clone --depth=1 https://github.com/asdf-vm/asdf.git /opt/asdf &&\
cd /opt/asdf &&\
. /opt/asdf/asdf.sh &&\
asdf plugin add python &&\
asdf install python latest &&\
asdf global python latest &&\
asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git &&\
asdf install lua latest &&\
asdf global lua latest &&\
asdf plugin add nodejs &&\
asdf install nodejs latest &&\
asdf global nodejs latest &&\
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git &&\
asdf install golang latest &&\
asdf global golang latest

RUN . /opt/asdf/asdf.sh &&\
npm install -g yarn &&\
asdf reshim &&\
yarn config set prefix ~/.yarn &&\
yarn global add neovim npm-check-updates coffeescript node-pre-gyp \
diff-so-fancy pnpm rome@next @antfu/ni prettier \
@prettier/plugin-pug stylus-supremacy

RUN \
. /opt/asdf/asdf.sh &&\
asdf reshim &&\
go install mvdan.cc/sh/cmd/shfmt@latest &&\
go install github.com/muesli/duf@master &&\
go install github.com/louisun/heyspace@latest


RUN ln -s /usr/bin/gist-paste /usr/bin/gist &&\
cd /usr/local && \
wget https://cdn.jsdelivr.net/gh/junegunn/fzf/install -O fzf.install.sh &&\
bash ./fzf.install.sh && rm ./fzf.install.sh && cd ~ &&\
echo 'PATH=/opt/rust/bin:$PATH' >> /etc/profile.d/path.sh

COPY os/root /root

RUN declare -A ZINIT
ENV ZINIT_HOME /opt/zinit/zinit.git
ENV ZINIT[HOME_DIR]	/opt/zinit
ENV ZPFX /opt/zinit/polaris
RUN mkdir -p /opt/zinit && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME

RUN cat /root/.zinit.zsh|grep --invert-match "^zinit ice"|zsh &&\
    /opt/zinit/plugins/romkatv---powerlevel10k/gitstatus/install
COPY os/usr/share/nvim /usr/share/nvim
COPY os/etc/vim /etc/vim

RUN \
update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 1 &&\
update-alternatives --set vi /usr/bin/nvim &&\
update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 1 &&\
update-alternatives --set vim /usr/bin/nvim &&\
update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 1&&\
update-alternatives --set editor /usr/bin/nvim

RUN \
. /opt/asdf/asdf.sh &&\
curl -fLo /etc/vim/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&\
vi -E -s -u /etc/vim/sysinit.vim +PlugInstall +qa &&\
vi +'CocInstall -sync coc-json coc-yaml coc-css coc-python coc-vetur coc-tabnine coc-svelte' +qa &&\
find /etc/vim -type d -exec chmod 755 {} +

RUN . /opt/asdf/asdf.sh &&\
  pip install --upgrade pip glances pylint supervisor python-language-server ipython xonsh pynvim yapf flake8 &&\
  asdf reshim

WORKDIR /
COPY os .
COPY boot .

RUN . /opt/asdf/asdf.sh && \
  rm -rf /root/.cache/pip &&\
  python -m pip cache purge &&\
  go clean --cache &&\
  yarn cache clean --mirror &&\
  npm cache clean -f &&\
  apt-get clean -y &&\
  rm -rf /var/lib/apt/lists /var/tmp /tmp /var/log /var/cache/debconf /root/.npm &&\
  find / | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf

RUN mkdir -p /init/etc/rc.d && mv /etc/rc.d/* /init/etc/rc.d &&\
    mv /root /init && mkdir -p /root && echo "cp -r /init/* / && exec zsh" > /root/.zshrc

