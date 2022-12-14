FROM bash:5.2.12

WORKDIR /app
COPY script.sh .

RUN apk add curl && \
    apk add jq && \
    apk add bash
    
ADD etcdctl /usr/local/bin

RUN chmod 755 /app/script.sh

CMD ["bash"]