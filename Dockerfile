FROM alpine as builder

RUN apk add --no-cache git npm

RUN git clone https://github.com/verybadsoldier/ghome-fhem.git && \
    cd ghome-fhem && \
    git checkout 1.0.0 && \
    npm install && \
    cd frontend && \
    npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc && \
    bower install


FROM alpine

RUN apk add --no-cache bash nodejs

COPY --from=builder /ghome-fhem ghome-fhem

RUN mkdir /ghome-fhem-config && wget https://dl.google.com/gactions/updates/bin/linux/amd64/gactions/gactions -O /ghome-fhem-config/gactions && \
    chmod +x /ghome-fhem-config/gactions

COPY config/* /ghome-fhem-config/

WORKDIR /ghome-fhem

VOLUME /ghome-fhem-config
EXPOSE 3000

CMD ["/ghome-fhem/bin/ghome", "-U", "/ghome-fhem-config"]
