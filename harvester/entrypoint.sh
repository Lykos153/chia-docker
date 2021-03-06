#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
    CA_DIR=/ca
    PLOT_DIR=/plots

    for varname in FARMER_PEER FARMER_PORT LOG_LEVEL; do
        if [ -z "${!varname}" ]; then
            echo "ERROR: $varname is not set."
            exit 1
        fi
    done

    for dirname in "$CA_DIR" "$PLOT_DIR"; do
        if [ ! -d "${dirname}" ]; then
            echo "ERROR: $dirname is not mounted or is not a directory."
            exit 1
        fi
    done

    mainnet_dir="$HOME/.chia/mainnet"
    config_file="$mainnet_dir/config/config.yaml"

    chia init
    chia init -c "$CA_DIR"
    chia plots add -d "$PLOT_DIR"


    if [ "$DISABLE_IP6" == "true" ]; then
        sed -i 's/localhost/127.0.0.1/g' "$config_file"
    fi
    yq --inplace e "
                    .harvester.farmer_peer.host     = \"$FARMER_PEER\" |
                    .harvester.farmer_peer.port     = $FARMER_PORT |
                    .harvester.logging.log_level    = \"$LOG_LEVEL\" |
                    .harvester.logging.log_stdout   = true
                " "$config_file"

    if [ -n "$LOG_FILE" ]; then
        yq --inplace e "
                        .harvester.logging.log_filename         = \"$LOG_FILE\" |
                        .harvester.logging.log_maxfilesrotation = 7
                    " "$config_file"
    fi

    chia start harvester
    harvester_pid="$(cat "$HOME/.chia/mainnet/run/chia_harvester.pid")"
    tail --pid="$harvester_pid" -f /dev/null

else
    exec $@
fi
