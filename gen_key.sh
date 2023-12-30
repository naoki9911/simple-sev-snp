#!/bin/bash

set -eux

openssl ecparam -genkey -name secp384r1 -noout -out sev-id.key
openssl ecparam -genkey -name secp384r1 -noout -out sev-author.key

