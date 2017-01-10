FROM golang:1.7
MAINTAINER DispatchBot <ops@dispatchbot.com>

# install pyyaml
RUN cd /tmp && wget http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz && tar -zxvf PyYAML-3.11.tar.gz
RUN cd /tmp/PyYAML-3.11 && python setup.py install
# install glide
RUN go get github.com/Masterminds/glide

COPY . $GOPATH/src/github.com/ingensi/dockbeat
RUN cd $GOPATH/src/github.com/ingensi/dockbeat && make && make

RUN mkdir -p /etc/dockbeat/ \
    && cp $GOPATH/src/github.com/ingensi/dockbeat/dockbeat /usr/local/bin/dockbeat \
    && cp $GOPATH/src/github.com/ingensi/dockbeat/dockbeat-docker.yml /etc/dockbeat/dockbeat.yml

RUN wget https://s3.amazonaws.com/dispatchbot-devops/ca-chain.cert.pem && \
  mv ca-chain.cert.pem /usr/local/share/ca-certificates/dispatchbot-ca-chain.cert.crt && \
  update-ca-certificates

WORKDIR /etc/dockbeat
ENTRYPOINT dockbeat

CMD [ "-c", "dockbeat.yml", "-e" ]
