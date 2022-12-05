FROM ruby:2.7.4

WORKDIR /src
COPY . /src

ENV NODE_VERSION=6.9.1

RUN apt-get -yqq update

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
                        && nvm use v${NODE_VERSION} \
                        && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN gem update --system
RUN gem install bundler
