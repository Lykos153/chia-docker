#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
    CA_DIR=/ca

    for varname in PORT INTRODUCER_PEER INTRODUCER_PORT LOG_LEVEL; do
        if [ -z "${!varname}" ]; then
            echo "ERROR: $varname is not set."
            exit 1
        fi
    done

    if [ ! -d "$CA_DIR" ]; then
        echo "ERROR: $CA_DIR is not mounted."
        exit 1
    fi

    mainnet_dir="$HOME/.chia/mainnet"
    config_file="$mainnet_dir/config/config.yaml"

    chia init >/dev/null
    chia init -c "$CA_DIR"

    if [ "$DISABLE_IP6" == "true" ]; then
        sed -i 's/localhost/127.0.0.1/g' "$config_file"
    fi
    yq --inplace e "
                    .full_node.introducer_peer.host     = \"$INTRODUCER_PEER\" |
                    .full_node.introducer_peer.port     = $INTRODUCER_PORT |
                    .full_node.port                    = $PORT |
                    .full_node.logging.log_level       = \"$LOG_LEVEL\" |
                    .full_node.logging.log_stdout      = true
                " "$config_file"

    if [ -n "$LOG_FILE" ]; then
        yq --inplace e "
                        .full_node.logging.log_filename         = \"$LOG_FILE\" |
                        .full_node.logging.log_maxfilesrotation = 7
                    " "$config_file"
    fi

    chia start node
    node_pid="$(cat "$HOME/.chia/mainnet/run/chia_full_node.pid")"
    tail --pid="$node_pid" -f /dev/null

else
    exec $@
fi
