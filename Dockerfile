FROM node:8-jessie as builder

RUN apt-get update;apt-get -y install git node npm wget

RUN git clone https://github.com/verybadsoldier/ghome-fhem.git && \
    cd ghome-fhem && \
    git checkout 1.0.0 && \
    npm install && \
    cd frontend && \
    wget https://dl.google.com/gactions/updates/bin/linux/amd64/gactions/gactions -O /tmp/gactions && \
    npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc


FROM node:8-jessie

RUN apt-get update;apt-get -y install bash dnsutils ipset && rm -rf /etc/apt/cache/*

COPY --from=builder /ghome-fhem ghome-fhem

RUN mkdir /ghome-fhem-config

COPY --from=builder /tmp/gactions /ghome-fhem-config/gactions
RUN chmod +x /ghome-fhem-config/gactions

COPY config/* /ghome-fhem-config/

WORKDIR /ghome-fhem

VOLUME /ghome-fhem-config

ENV TCP_PORT=3000
ENV IPSET_NAME="google"
ENV CHAIN_NAME="GOOGLE-WHITELIST"
ENV TARGET_CHAINS="INPUT"

ADD google_iprange_update.sh /bin
RUN chmod +x /bin/google_iprange_update.sh

EXPOSE 3000

ENTRYPOINT (/bin/google_iprange_update.sh)& /ghome-fhem/bin/ghome -U /ghome-fhem-config
