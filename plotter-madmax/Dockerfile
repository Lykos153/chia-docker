FROM odelucca/chia-plotter

RUN apk add --no-cache rsync netcat-openbsd curl bind-tools

ENV FINAL_DIR /plots
ENV TMP_DIR /temp1
ENV TMP2_DIR /temp2
ENV THREADS 4
ENV NUMBER 1
ENV TRANSFER_RETRY_SEC 30
ENV TARPIPE_PORT 3000
ENV FTP_PORT 21


ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /
