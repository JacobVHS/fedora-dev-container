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
    awscli \
    https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm \
    && dnf clean all

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install k9s
RUN curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz" \
    && tar -xzf k9s_Linux_amd64.tar.gz \
    && mv k9s /usr/local/bin/ \
    && rm k9s_Linux_amd64.tar.gz

# Install oc
RUN curl -LO "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz" \
    && tar -xzf openshift-client-linux.tar.gz \
    && mv oc kubectl /usr/local/bin/ \
    && rm openshift-client-linux.tar.gz

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