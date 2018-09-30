FROM perl:5.22-slim

ENV PERL_MM_USE_DEFAULT=1 PERL_CARTON_PATH=/carton

COPY cpanfile cpanfile.snapshot /metacpan-web/
WORKDIR /metacpan-web

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       gcc \
       libc6-dev \
       libexpat1-dev \
       libssl-dev \
       libxml2-dev \
       zlib1g-dev \
    && cpanm App::cpm \
    && cpm install -g Carton \
    && useradd -m metacpan-web -g users \
    && mkdir /carton \
    && cpm install -L /carton \
    && chown -R metacpan-web:users /metacpan-web /carton \
    && apt-mark auto '.*' > /dev/null \
    && apt-mark manual libexpat1 libssl1.1 libxml2 zlib1g \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -fr /var/lib/apt/lists/* /var/cache/apt/* \
    && rm -fr /root/.cpanm /root/.perl-cpm /tmp/*

VOLUME /carton

USER metacpan-web:users

EXPOSE 5001

CMD ["carton", "exec", "plackup", "-p", "5001", "-r"]
