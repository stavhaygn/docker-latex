FROM debian:bullseye

RUN set -eux; \
    apt-get -qq update; \
    apt-get install -yqq --no-install-recommends \
    ca-certificates \
    git \
    make \
    openssh-server \
    wget \
    ;

# Install LaTeX packages
# Reference: https://github.com/arikoi0703/docker/blob/master/vscode/latex/Dockerfile
RUN set -eux; \
    apt-get install -yqq --no-install-recommends \ 
    latex-cjk-all \
    texlive-base \
    texlive-bibtex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-latex-recommended \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd \
    && sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config \
    && sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config \
    && sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" /etc/ssh/sshd_config \
    && sed -i "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config 

RUN useradd -ms /bin/bash latex && echo "latex:latexlatex" | chpasswd
WORKDIR /workspace
RUN chown -R latex:latex "$PWD"

# Install latexmk and latexindent for Visual Studio Code LaTeX Workshop Extension
# Reference: https://github.com/James-Yu/LaTeX-Workshop/wiki/Install#requirements
# Reference: https://github.com/csg-projects/latexindent-dockerfile/blob/master/latexindent.dockerfile
RUN set -eux; \
    apt-get -qq update; \
    apt-get install -yqq --no-install-recommends \
    build-essential \
    cmake \
    cpanminus \
    latexmk \
    ; \
    rm -rf /var/lib/apt/lists/*

ENV LATEXINDENT_VERSION V3.17.2
WORKDIR /

RUN git clone -b "$LATEXINDENT_VERSION" https://github.com/cmhughes/latexindent.pl.git

RUN set -eux; \
    cd /latexindent.pl/helper-scripts; \
    echo "Y" | perl latexindent-module-installer.pl

RUN set -eux; \
    cd /latexindent.pl; \
    mkdir build; \
    cd build; \
    cmake ../path-helper-files; \
    make install; \
    ln -s /usr/local/bin/latexindent.pl /usr/local/bin/latexindent; \
    cd /; \
    rm -rf /latexindent.pl

WORKDIR /workspace

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
