FROM alpine:3.9

MAINTAINER Alexey Kutepov <reximkut@gmail.com>

VOLUME ["/tmp/hypernerd"]

RUN apk add --no-cache openssl-dev
RUN apk add --no-cache curl
RUN apk add --no-cache ghc
RUN apk add --no-cache cabal
RUN apk add --no-cache gmp-dev
RUN apk add --no-cache build-base
RUN apk add --no-cache zlib-dev

RUN cabal update
RUN mkdir /hypernerd/
COPY ./HyperNerd.cabal /hypernerd/
COPY ./Setup.hs /hypernerd/
WORKDIR /hypernerd/
RUN cabal sandbox init
RUN cabal install happy-1.19.9
RUN cabal install --only-dependencies
COPY ./resources/ /hypernerd/resources/
COPY ./src/ /hypernerd/src/
RUN cabal build exe:HyperNerd

CMD ["/hypernerd/dist/build/HyperNerd/HyperNerd", "/tmp/hypernerd/secret.ini", "/tmp/hypernerd/database.db", "/tmp/hypernerd/markov.csv"]
