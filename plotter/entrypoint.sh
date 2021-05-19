#!/bin/bash
set -e
_term() {
    RED='\033[0;31m'
    NC='\033[0m'
    printf "${RED}CAUGHT STOP SIGNAL!${NC} "
    echo "Stopping when current plot is finished"
    wait $plot_pid
}

trap _term SIGTERM
trap _term SIGINT

if [ "$#" -eq 0 ]; then

    for varname in FARMER_PUBKEY POOL_PUBKEY; do
        if [ -z "${!varname}" ]; then
            echo "ERROR: $varname is not set."
            exit 1
        fi
    done

    mkdir -p "${TMP_DIR-/}" "${TMP2_DIR-/}" "${FINAL_DIR-/}"

    plot_cmd="plotter"
    plot_args="-x -f$FARMER_PUBKEY -p$POOL_PUBKEY -d$FINAL_DIR"
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
    if [ "$TEST_MODE" == "yes" ]; then
        plot_cmd+=" --override-k"
        : ${SIZE:=25}
    fi
    if [ -n "$SIZE" ]; then
        plot_cmd+=" -k$SIZE"
    fi


    chia init > /dev/null
    if [ "$NUMBER" == "infinity" ]; then
        while [ "$STOP" != "true" ]
        do
            $plot_cmd -n1 $plot_args &
            plot_pid=$!
            wait $plot_pid
        done
    else
        $plot_cmd -n$NUMBER $plot_args &
        plot_pid=$!
        wait $plot_pid
        ret=$?
        exit $ret
    fi
else
    exec $@
fi
