FROM bash:5.2.12

WORKDIR /app

RUN apk add curl && \
    apk add jq && \
    apk add bash
    
ADD etcdctl /usr/local/bin
ADD etcdctldefrag /usr/local/bin

CMD ["bash"]