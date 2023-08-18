#!/bin/bash -

emane-jammer-simple-control -v node-4:45715 on 4 2360000000,5 2460000000,5 2410000000,5 -a omni

echo 'use `emane-jammer-simple-control node-4:45715 off` to stop'
