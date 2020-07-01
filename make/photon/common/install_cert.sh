#!/bin/sh

set -e

if grep -q "Photon" /etc/lsb-release; then

    if [ ! -f ~/ca-bundle.crt.original ]; then
        cp /etc/pki/tls/certs/ca-bundle.crt ~/ca-bundle.crt.original
    fi

    cp ~/ca-bundle.crt.original /etc/pki/tls/certs/ca-bundle.crt

    if [ "$(ls -A /harbor_cust_cert)" ]; then
        echo "Appending trust CA to ca-bundle ..."
        for z in /harbor_cust_cert/*; do
            case ${z} in
                *.crt | *.ca | *.ca-bundle | *.pem)
                    if [ -d "$z" ]; then
                        echo "$z is dirictory, skip it ..."
                    else
                        cat $z >> /etc/pki/tls/certs/ca-bundle.crt
                        echo " $z Appended ..."
                    fi
                    ;;
                *) echo "$z is Not ca file ..." ;;
            esac
        done
        echo "CA appending is Done."
    fi
elif grep -q "SLES" /etc/os-release; then
    if [ "$(ls -A /harbor_cust_cert)" ]; then
        echo "Installing trust CA ..."
        for z in /harbor_cust_cert/*; do
            case ${z} in
                *.crt | *.ca | *.ca-bundle | *.pem)
                    if [ -d "$z" ]; then
                        echo "$z is directory, skip it ..."
                    else
                        cp $z /etc/pki/trust/anchors
                        echo " $z Appended ..."
                    fi
                    ;;
                *) echo "$z is Not ca file ..." ;;
            esac
        done
        /usr/sbin/update-ca-certificates
        echo "CA installing is Done."
    fi
else
    echo "Current OS is not supported, skip appending ca bundle"
fi
