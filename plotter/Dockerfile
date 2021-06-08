ARG CHIA_VERSION
FROM lykos153/chia-base:${CHIA_VERSION}

RUN apt-get update && apt-get install -y rsync netcat-openbsd

ENV FINAL_DIR /plots
ENV TMP_DIR /tmp
ENV NUMBER 1
ENV TRANSFER_RETRY_SEC 30
ENV TARPIPE_PORT 3000


ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /
COPY plotter /usr/local/bin
