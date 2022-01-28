FROM golang:1.17-buster AS go-builder

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apt update
RUN apt install -y curl git build-essential
# debug: for live editting in the image
RUN apt install -y vim

WORKDIR /code
COPY . /code/

RUN LEDGER_ENABLED=false make build

ADD https://github.com/mandrean/wasmvm/releases/download/v0.16.3-arm64/libwasmvm.so /lib/libwasmvm.so
RUN sha256sum /lib/libwasmvm.so | grep 4a50ccdde91bc39b90ebbd79826825ca4969344f16e8269816536761d723b6b2

FROM ubuntu:20.04

WORKDIR /root

COPY --from=go-builder /code/build/terrad /usr/local/bin/terrad
COPY --from=go-builder /lib/libwasmvm.so /lib/libwasmvm.so

# rest server
EXPOSE 1317
# grpc
EXPOSE 9090
# tendermint p2p
EXPOSE 26656
# tendermint rpc
EXPOSE 26657

CMD ["/usr/local/bin/terrad", "version"]
