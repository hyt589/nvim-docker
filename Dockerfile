FROM nvcr.io/nvidia/l4t-base:r32.5.0

# Locales
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update && apt install -y locales && locale-gen en_US.UTF-8

# Colors and italics for tmux
COPY xterm-256color-italic.terminfo /root
RUN tic /root/xterm-256color-italic.terminfo
ENV TERM=xterm-256color-italic

RUN apt install -y software-properties-common \
    supervisor \
    apt-utils

RUN add-apt-repository ppa:neovim-ppa/unstable && apt-get update

RUN apt-get install -y neovim

RUN apt-get install -y zsh \
    tmux \
    build-essential \
    wget \
    jq \
    net-tools \
    zip

RUN rm /bin/sh && ln -s /bin/zsh /bin/sh

RUN mkdir -p /root/bin

ENV PATH=/root/bin:$PATH

RUN mkdir -p ~/resources && cd ~/resources  \
    && wget https://github.com/Kitware/CMake/releases/download/v3.20.4/cmake-3.20.4-linux-aarch64.tar.gz \
    && tar -xvf cmake-3.20.4-linux-aarch64.tar.gz && rm *.tar.gz \
    && ln -sf $(pwd)/cmake-3.20.4-linux-aarch64/bin/cmake /root/bin/cmake \
    && chmod +x /root/bin/cmake

RUN apt-get install -y git && cd ~ && sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

RUN mkdir -p ~/resources && cd ~/resources && git clone --depth 1 --branch llvmorg-11.0.0 https://github.com/llvm/llvm-project.git && \
    cd llvm-project && mkdir build && cd build && \
    /root/bin/cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" ../llvm && \
    make clangd -j4 && ln -sf $(pwd)/bin/clangd /root/bin/clangd

COPY dotfiles/vim/.vim/ /root/.vim/
COPY dotfiles/vim/.config/nvim/ /root/.config/nvim/
COPY dotfiles/git/.gitconfig /root/.gitconfig

RUN apt-get install -y curl \
    && curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN cd ~ \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

RUN apt-get install -y python3-pip && python3 -m pip install --upgrade pynvim ranger-fm

ENV TERM=xterm-256color-italic

#RUN npm install -g tree-sitter-cli

RUN nvim --headless +PlugInstall +qall

RUN nvim --headless +"CocInstall -sync coc-clangd coc-pyright coc-marketplace coc-json coc-docker coc-cmake coc-sh coc-snippets coc-pairs coc-vimlsp" +qall  && \
    nvim --headless +"TSInstallSync all" +qall

RUN mkdir -p /workspace

RUN apt install -y clang-format-10 gdb && \
    ln -sf $(readlink -f $(which clang-format-10)) /root/bin/clang-format

COPY .zshrc /root/.zshrc

WORKDIR /workspace

CMD zsh
