#!/bin/bash

# Installs VA certificates

# Downloads certificates from certificate authority
mkdir -p /usr/local/share/ca-certificates/
cd /usr/local/share/ca-certificates/
wget --no-check-certificate -r -l1 --no-parent -A.cer http://aia.pki.va.gov/PKI/AIA/VA/ -P .

# Converts certificate format to expected PEM format
find aia.pki.va.gov -name '*.cer' | while read FILE; do export NAME=${FILE//.cer}; openssl x509 -inform DER -in ${NAME}.cer -out ${NAME}.crt; done

mv ./aia.pki.va.gov/PKI/AIA/VA ./VA
rm -rf aia.pki.va.gov
find VA  -name '*.cer' -delete
chmod -R 644 VA

# Updates system certificates (Debian)
dpkg-reconfigure -p critical ca-certificates
update-ca-certificates

