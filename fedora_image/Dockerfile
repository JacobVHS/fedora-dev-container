FROM fedora:latest

USER root
WORKDIR /tmp

COPY shells /etc/shells
COPY bashrc /home/jacob/.bashrc
COPY zshrc /home/jacob/.zshrc
COPY shell_aliases /home/jacob/.shell_aliases
COPY tmux.conf /home/jacob/.tmux.conf

# Install required packages using dnf
RUN dnf install -y \
    python3 \
    python3-pip \
    python3-devel \
    gcc \
    gcc-c++ \
    make \
    zsh \
    curl \
    ansible-core \
    bat \
    zsh-syntax-highlighting \
    git \
    tmux \
    tree \
    podman \
    vim \
    neovim \
    psutils \
    fzf \
    && dnf clean all

# Create jacob user
RUN useradd -m -s /usr/bin/zsh jacob

# Set zsh as the default shell for the jacob user
RUN usermod -s /usr/bin/zsh jacob

# Create ansible directories
RUN mkdir -p /.ansible/roles /.ansible/collections /.ansible/modules && touch /.ansible/.lock

# In OpenShift, container will run as a random uid number and gid 0. Make sure things
# are writeable by the root group.
RUN chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home /.ansible/.lock

# Set the default shell for the container
SHELL ["/usr/bin/zsh", "-c"]

# Copy over config dir
COPY config /home/jacob/.config
RUN git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

# Add starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Fix ownership for jacob user
RUN chown -R jacob:jacob /home/jacob
RUN echo 'jacob ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jacob
USER jacob
WORKDIR /home/jacob