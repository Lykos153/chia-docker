#!/bin/sh
_term() {
    RED='\033[0;31m'
    NC='\033[0m'
    printf "${RED}CAUGHT STOP SIGNAL!${NC} "
    echo "Stopping when current plot is finished"
    wait $plot_pid
}

trap _term SIGTERM
trap _term SIGINT



rsync_plot() {
    until rsync -vPh --preallocate --remove-source-files "$FINAL_DIR"/*.plot "$RSYNC_TARGET"
    do
        echo "Couldn't send plot to rsync destination. Retrying in $TRANSFER_RETRY_SEC seconds"
        sleep "$TRANSFER_RETRY_SEC"
    done
}

tarpipe_plot() {
    (
        cd "$FINAL_DIR"
        shopt -s nullglob # https://unix.stackexchange.com/a/162589
        for plot in *.plot; do
            echo "Sending $plot via tarpipe to $TARPIPE_HOST:$TARPIPE_PORT..."
            until
                tar -c "$plot" | nc -q1 "$TARPIPE_HOST" "$TARPIPE_PORT" >/dev/null &&
                rm "$plot"
            do
                echo "Couldn't send $plot to tarpipe destination. Retrying in $TRANSFER_RETRY_SEC seconds"
                sleep "$TRANSFER_RETRY_SEC"
            done
        done
    )
}

next_plot() {
    (
        set -o pipefail
        plot="$(ls "$FINAL_DIR"/*.plot 2>/dev/null | head -n1)"
        if [ -n "$plot" ]; then
            echo "$plot"
            return 0
        else
            return 1
        fi
    )
}


_ftp_send() {
    plot="$1"
    ipa="$2"

    options=""
    if [ -n "$FTP_USER" ] && [ -n "$FTP_PASSWORD" ]; then
        netrc="$HOME/.netrc"
        echo "machine $ipa" > "$netrc"
        echo "login $FTP_USER" >> "$netrc"
        echo "password $FTP_PASSWORD" >> "$netrc"
        options+="--netrc-file $netrc"
    fi
    curl $options --upload-file "$plot" "ftp://$ipa" || return 1
}

ftp_plot() {
    echo "Sending plot via FTP..."
    while next_plot; do
        plot=$(next_plot)
        if [ "$TRY_ALL_IPS" == "yes" ]; then
            for ipa in $(dig "$FTP_HOST" +short); do
                echo "Sending $plot to ftp://$ipa..."
                _ftp_send "$plot" "$ipa"
                ret=$?
                if [ "$ret" -eq 0 ]; then
                    break
                fi
            done
        else
            _ftp_send "$plot" "$FTP_HOST"
            ret=$?
        fi
        if [ "$ret" -eq 0 ]; then
            rm "$plot"
            if [ $? -ne 0 ]; then
                echo "Error deleting $plot."
                exit 1
            fi
        else
            echo "Couldn't send $plot to ftp://$FTP_HOST. Retrying in $TRANSFER_RETRY_SEC seconds"
            sleep "$TRANSFER_RETRY_SEC"
        fi
        sleep 5
    done
}

if [ "$#" -eq 0 ]; then

    if [ -z "$FARMER_PUBKEY" ]; then
        echo "ERROR: FARMER_PUBKEY is not set."
        exit 1
    fi
    if [ -z "$POOL_PUBKEY" ]; then
        echo "ERROR: POOL_PUBKEY is not set."
        exit 1
    fi

    mkdir -p "${TMP_DIR-/chia}" "${TMP2_DIR-/chia}" "${FINAL_DIR-/chia}"
    TMP_DIR="$(realpath $TMP_DIR)/"
    TMP2_DIR="$(realpath $TMP2_DIR)/"
    FINAL_DIR="$(realpath $FINAL_DIR)/"

    plot_cmd="chia_plot"
    plot_args=" -f $FARMER_PUBKEY -p $POOL_PUBKEY -d $FINAL_DIR -r $THREADS -t $TMP_DIR -2 $TMP2_DIR"

    plot_count=0
    while [ "$STOP" != "true" ]
    do
        plot_count=$((plot_count+1))
        echo "Plot count: $plot_cound"
        $plot_cmd -n 1 $plot_args &
        plot_pid=$!
        wait $plot_pid
        
        if [ -n "$RSYNC_TARGET" ]; then
            rsync_plot
        elif [ -n "$TARPIPE_HOST" ]; then
            tarpipe_plot
        elif [ -n "$FTP_HOST" ]; then
            ftp_plot
        fi

        if [ "$plot_count" -eq "$NUMBER" ]; then
            STOP="true"
        fi
        sleep 1
    done
else
    exec $@
fi
