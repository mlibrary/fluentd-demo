from ruby:3.2

ARG UNAME=app
ARG UID=1000
ARG GID=1000

RUN gem install bundler
ENV BUNDLE_PATH /gems

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

WORKDIR /app
USER $UNAME

COPY --chown=${UID}:${GID} . /app
RUN bundle install
