FROM ruby:3.1.1-alpine

RUN apk fix \
    && apk --update add git git-lfs openssh docker-compose bash sudo

RUN mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keygen -A


RUN addgroup -S docco \
    && adduser -G docco -h /home/docco \
    -s /usr/bin/git-shell -D docco \
    && passwd -u docco \
    && adduser docco wheel \
    && mkdir -p /etc/sudoers.d \
    && echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
    && chmod 0440 /etc/sudoers.d/wheel

WORKDIR /home/docco

RUN mkdir .ssh && chmod 700 .ssh

COPY docco docco
COPY scripts scripts
COPY lib lib
COPY Gemfile Gemfile.lock base_cli.rb ./
RUN ln -s scripts git-shell-commands
COPY docco-docker.env docco.env
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install -j4
RUN chown -R docco:docco /home/docco
RUN sudo -u docco bundle config set --local path 'vendor/bundle'

COPY sshd_config /etc/ssh/sshd_config
COPY start.sh start.sh

EXPOSE 22

CMD ["sh", "start.sh"]
