ARG CHIA_VERSION
FROM lykos153/chia-base:${CHIA_VERSION}

COPY --from=mikefarah/yq:4.9.1 /usr/bin/yq /usr/local/bin/yq

ENTRYPOINT ["/entrypoint.sh"]

ENV DISABLE_IP6 true
ENV INTRODUCER_PEER introducer.chia.net
ENV INTRODUCER_PORT 8444
ENV PORT 8444
ENV LOG_LEVEL INFO

COPY entrypoint.sh /
