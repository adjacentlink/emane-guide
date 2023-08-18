#!/bin/bash -

emane-spectrum-analyzer \
    10.99.0.5:8883 \
    -100 \
    --with-waveforms \
    --hz-min 2350000000 \
    --hz-max 2500000000 \
    --subid-name 1,IEEE802.11


