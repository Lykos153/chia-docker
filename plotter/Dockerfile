ARG CHIA_VERSION
FROM lykos153/chia-base:${CHIA_VERSION}

RUN apt-get update && apt-get install -y rsync

ENV FINAL_DIR /plots
ENV TMP_DIR /tmp
ENV NUMBER 1
ENV RSYNC_RETRY_SEC 30


ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /
COPY plotter /usr/local/bin
