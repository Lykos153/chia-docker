ARG CHIA_VERSION
FROM lykos153/chia-base:${CHIA_VERSION}

ENV FINAL_DIR /plots
ENV TMP_DIR /tmp
ENV NUMBER 1


ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /
COPY plotter /usr/local/bin
