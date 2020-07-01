#!/bin/sh

set -e

if [[ -f /etc/lsb-release ]] && grep -q "Photon" /etc/lsb-release; then

    if [ ! -f ~/ca-bundle.crt.original ]; then
        cp /etc/pki/tls/certs/ca-bundle.crt ~/ca-bundle.crt.original
    fi

    cp ~/ca-bundle.crt.original /etc/pki/tls/certs/ca-bundle.crt

    # Install /etc/harbor/ssl/{component}/ca.crt to trust CA.
    if [[ -d /etc/harbor/ssl ]]; then 
        echo "Appending internal tls trust CA to ca-bundle ..."
        for caFile in `find /etc/harbor/ssl -maxdepth 2 -name ca.crt`; do
            cat $caFile >> /etc/pki/tls/certs/ca-bundle.crt
            echo "Internal tls trust CA $caFile appended ..."
        done
        echo "Internal tls trust CA appending is Done."
    fi
    if [[ -d /harbor_cust_cert && -n "$(ls -A /harbor_cust_cert)" ]]; then
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

elif [[ -f /etc/os-release ]] && grep -q "SLES" /etc/os-release; then

    # Install /etc/harbor/ssl/{component}/ca.crt.
    if [[ -d /etc/harbor/ssl ]]; then 
        echo "Installing internal tls trust CA ..."
        for caFile in `find /etc/harbor/ssl -maxdepth 2 -name ca.crt`; do
            relpath=$(realpath -s --relative-to=/etc/harbor/ssl $caFile)
            cp $caFile /etc/pki/trust/anchors/${relpath//\//_}
            echo "Internal tls trust CA $caFile installed ..."
        done
        /usr/sbin/update-ca-certificates
        echo "Internal tls trust CA installing is Done."
    fi
    if [[ -d /harbor_cust_cert && -n "$(ls -A /harbor_cust_cert)" ]]; then
        echo "Installing trust CA ..."
        for z in /harbor_cust_cert/*; do
            case ${z} in
                *.crt | *.ca | *.ca-bundle | *.pem)
                    if [ -d "$z" ]; then
                        echo "$z is a directory, skip it ..."
                    else
                        cp $z /etc/pki/trust/anchors
                        echo " $z Installed ..."
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
