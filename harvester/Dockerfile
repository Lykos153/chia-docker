ARG CHIA_VERSION
FROM lykos153/chia-base:${CHIA_VERSION}


COPY --from=mikefarah/yq:4.9.1 /usr/bin/yq /usr/local/bin/yq

ENV DISABLE_IP6 true
ENV FARMER_PORT 8447
ENV LOG_LEVEL INFO

ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /
