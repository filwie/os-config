FROM archlinux/base

ARG packages="openssh"

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen

RUN pacman -Sy --needed --noconfirm ${packages} > /dev/null

RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa

COPY ./host_pubkey /root/.ssh/authorized_keys

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
