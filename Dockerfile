FROM ruby:3.1.1-alpine

RUN apk fix \
    && apk --update add git git-lfs openssh docker-compose bash docker

RUN mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keygen -A


RUN addgroup -S docco \
    && adduser -G docco -h /home/docco \
    -s /usr/bin/git-shell -D docco \
    && passwd -u docco

WORKDIR /home/docco

RUN mkdir .ssh && chmod 700 .ssh

COPY docco docco
COPY scripts scripts
COPY lib lib
COPY Gemfile Gemfile.lock ./
RUN ln -s scripts git-shell-commands
COPY docco-docker.env docco.env
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install -j4
RUN chown -R docco:docco /home/docco
USER docco
RUN bundle config set --local path 'vendor/bundle'
USER root

COPY sshd_config /etc/ssh/sshd_config
COPY start.sh start.sh

EXPOSE 22

CMD ["sh", "start.sh"]
