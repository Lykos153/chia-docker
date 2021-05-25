#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
    CA_DIR=/ca
    FARMING_KEY_FILE=/farming_keys


    for varname in FULL_NODE_PEER FULL_NODE_PORT PORT TARGET_ADDRESS POOL_ADDRESS; do
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

    if [ -f "$FARMING_KEY_FILE" ] && [ -s "$FARMING_KEY_FILE" ]; then
        while IFS='' read -r line || [ -n "${line}" ]; do # Catch files that don't end with newline https://unix.stackexchange.com/a/580545
            echo $line | chia keys add | grep "Setting the xch destination"
        done < "$FARMING_KEY_FILE"
    elif [ -d "$FARMING_KEY_FILE" ]; then
        for f in "$FARMING_KEY_FILE"/*; do
            while IFS='' read -r line || [ -n "${line}" ]; do
                echo $line | chia keys add | grep "Setting the xch destination"
            done < "$f"
        done
    else
        echo "ERROR: "$FARMING_KEY_FILE" is not mounted or is empty."
        exit 1
    fi

    if [ "$DISABLE_IP6" == "true" ]; then
        sed -i 's/localhost/127.0.0.1/g' "$config_file"
    fi
    yq --inplace e "
                    .farmer.full_node_peer.host     = \"$FULL_NODE_PEER\" |
                    .farmer.full_node_peer.port     = $FULL_NODE_PORT |
                    .farmer.port                    = $PORT |
                    .farmer.xch_target_address      = \"$TARGET_ADDRESS\" |
                    .pool.xch_target_address        = \"$POOL_ADDRESS\" |
                    .farmer.logging.log_level       = \"$LOG_LEVEL\" |
                    .farmer.logging.log_stdout      = true
                " "$config_file"

    if [ -n "$LOG_FILE" ]; then
        yq --inplace e "
                        .farmer.logging.log_filename         = \"$LOG_FILE\" |
                        .farmer.logging.log_maxfilesrotation = 7
                    " "$config_file"
    fi

    chia start farmer-only
    farmer_pid="$(cat "$HOME/.chia/mainnet/run/chia_farmer.pid")"
    tail --pid="$farmer_pid" -f /dev/null

else
    exec $@
fi
