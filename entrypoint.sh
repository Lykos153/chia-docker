#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then

    for varname in FARMER_PUBKEY POOL_PUBKEY; do
        if [ -z "${!varname}" ]; then
            echo "ERROR: $varname is not set."
            exit 1
        fi
    done

    mkdir -p "${TMP_DIR-/}" "${TMP2_DIR-/}" "${FINAL_DIR-/}"

    plot_cmd="chia plots create -f$FARMER_PUBKEY -p$POOL_PUBKEY -d$FINAL_DIR"
    if [ -n "$BUFFER" ]; then
        plot_cmd+=" -b$BUFFER"
    fi
    if [ -n "$THREADS" ]; then
        plot_cmd+=" -r$THREADS"
    fi
    if [ -n "$TMP_DIR" ]; then
        plot_cmd+=" -t$TMP_DIR"
    fi
    if [ -n "$TMP2_DIR" ]; then
        plot_cmd+=" -2$TMP2_DIR"
    fi
    if [ -n "$SIZE" ]; then
        plot_cmd+=" -k$SIZE"
    fi
    if [ "$TEST_MODE" == "yes" ]; then
        plot_cmd+=" --override-k"
    fi


    chia init > /dev/null
    if [ "$NUMBER" == "infinity" ]; then
        while [ ! -f /root/stoprun ]
        do
            $plot_cmd -n1
        done
    else
        $plot_cmd -n$NUMBER
    fi
else
    exec $@
fi
