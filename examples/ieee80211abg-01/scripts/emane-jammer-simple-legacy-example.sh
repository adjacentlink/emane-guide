#!/bin/bash -

emane-jammer-simple \
    --power 5 \
    -i letce0 \
    --bandwidth 20000000 \
    4  \
    2360000000 \
    2460000000 \
    2410000000
    $@

