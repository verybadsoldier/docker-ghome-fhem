FROM node:8-jessie as builder

RUN apt-get update;apt-get -y install git node npm wget

RUN git clone https://github.com/verybadsoldier/ghome-fhem.git && \
    cd ghome-fhem && \
    git checkout 1.0.0 && \
    npm install && \
    cd frontend && \
    npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc && \
    bower install


FROM node:8-jessie

COPY --from=builder /ghome-fhem ghome-fhem

RUN mkdir /ghome-fhem-config
COPY config/* /ghome-fhem-config/

WORKDIR /ghome-fhem

VOLUME /ghome-fhem-config

EXPOSE 3000

CMD ["/ghome-fhem/bin/ghome", "-U", "/ghome-fhem-config"]
