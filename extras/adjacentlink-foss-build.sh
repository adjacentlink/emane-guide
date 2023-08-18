#!/bin/bash -
#
# Copyright (c) 2017-2023 - Adjacent Link LLC, Bridgewater, New Jersey
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# * Neither the name of Adjacent Link LLC nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Python 3 build
export PYTHON=python3

# set to 1 to build emane-model-lte and srsRAN-emane
with_lte=1

dev_dir=$PWD

# read only access
clone_base=https://github.com/adjacentlink

# read only access
clone_base_environments_foss=https://github.com/sgalgano

# branches
emane_branch=master
openstatistic_branch=master
opentestpoint_branch=master
opentestpoint_probe_emane_branch=master
opentestpoint_probe_iproute_branch=master
opentestpoint_probe_iptraffic_branch=master
opentestpoint_probe_system_branch=master
opentestpoint_probe_mgen_branch=master
opentestpoint_labtools_branch=master
python_etce_branch=master
emane_node_director_branch=master
letce2_branch=master
letce2_plugin_lxc_branch=master
emane_spectrum_tools_branch=master
emane_jammer_simple_branch=master
emane_model_lte_branch=master
srsRAN_emane_branch=master
opentestpoint_probe_lte_branch=master
waveform_resource_branch=master

clone()
{
    pushd $dev_dir

    if [ ! -d $1 ]
    then
        git clone $clone_base/$1

        pushd $1

        git checkout $2

    else
        pushd $1

        git checkout $2

        git pull
    fi

    # apply any patches
    if [ -f ../$1.patch ]
    then
        patch -p 1 < ../$1.patch
    fi

    popd

    popd
}

build()
{
    echo "building: $dev_dir/$1"

    pushd $dev_dir/$1

    if [ -f ./autogen.sh ]
    then
        ./autogen.sh -c

        ./autogen.sh

        ./configure

        make

    elif [ -f CMakeLists.txt ]
    then
        mkdir build
        pushd build
        if (( $(echo "$(ldd --version | head -n 1 | awk '{print $4}')  > 2.17" |bc -l) ));
        then                                                                      
            cmake3 ..
        else
            cmake3 -DUSE_GLIBC_IPV6=0   ..
        fi
        make
        popd
    else
        make
    fi

    popd
}

build_all()
{
    # clone
    clone emane $emane_branch
    clone openstatistic $openstatistic_branch
    clone opentestpoint $opentestpoint_branch
    clone opentestpoint-probe-emane $opentestpoint_probe_emane_branch
    clone opentestpoint-probe-iproute $opentestpoint_probe_iproute_branch
    clone opentestpoint-probe-iptraffic $opentestpoint_probe_iptraffic_branch
    clone opentestpoint-probe-system $opentestpoint_probe_system_branch
    clone opentestpoint-probe-mgen $opentestpoint_probe_mgen_branch
    clone opentestpoint-labtools $opentestpoint_labtools_branch
    clone python-etce $python_etce_branch
    clone emane-node-director $emane_node_director_branch
    clone letce2 $letce2_branch
    clone letce2-plugin-lxc $letce2_plugin_lxc_branch
    clone emane-spectrum-tools $emane_spectrum_tools_branch
    clone emane-jammer-simple $emane_jammer_simple_branch
    clone waveform-resource $waveform_resource_branch
    
    if [ $with_lte -eq 1 ]
    then
        clone emane-model-lte $emane_model_lte_branch
        clone srsRAN-emane $srsRAN_emane_branch
        clone opentestpoint-probe-lte $opentestpoint_probe_lte_branch
    fi

    # clone and build latest environments-foss
    pushd $dev_dir
    git clone $clone_base_environments_foss/environments-foss
    pushd environments-foss
    if [ -f ../environments-foss.patch ]
    then
        patch -p 1 < ../environments-foss.patch
    fi
    make PYTHON=$PYTHON DEV_ROOT=$dev_dir
    popd
    popd

    # build base projects
    build emane
    build openstatistic
    build opentestpoint

    # load emane environment
    .  $dev_dir/environments-foss/adjacentlink-foss.env

    # build the rest
    build opentestpoint-probe-emane
    build opentestpoint-probe-iproute
    build opentestpoint-probe-iptraffic
    build opentestpoint-probe-system
    build opentestpoint-probe-mgen
    build opentestpoint-labtools
    build python-etce
    build emane-node-director
    build letce2
    build letce2-plugin-lxc
    build emane-spectrum-tools
    build waveform-resource
    
    if [ $with_lte -eq 1 ]
    then

        build emane-model-lte

        build srsRAN-emane

        build opentestpoint-probe-lte
    fi
}

clean_all()
{
    rm -rf \
       emane \
       emane-jammer-simple \
       emane-spectrum-tools \
       environments-foss \
       letce2 \
       letce2-plugin-lxc \
       openstatistic \
       opentestpoint \
       opentestpoint-labtools \
       opentestpoint-probe-emane \
       opentestpoint-probe-iproute \
       opentestpoint-probe-iptraffic \
       opentestpoint-probe-system \
       opentestpoint-probe-mgen \
       python-etce \
       emane-node-director\
       waveform-resource

    if [ $with_lte -eq 1 ]
    then
        rm -rf \
           emane-model-lte \
           srsRAN-emane \
           opentestpoint-probe-lte
    fi
}

make_patch_all()
{
    for project in emane \
                       emane-jammer-simple \
                       emane-spectrum-tools \
                       environments-foss \
                       letce2 \
                       letce2-plugin-lxc \
                       openstatistic \
                       opentestpoint \
                       opentestpoint-labtools \
                       opentestpoint-probe-emane \
                       opentestpoint-probe-iproute \
                       opentestpoint-probe-iptraffic \
                       opentestpoint-probe-system \
                       opentestpoint-probe-mgen \
                       python-etce \
                       emane-node-director\
                       waveform-resource
    do
        make_patch $project
    done

    if [ $with_lte -eq 1 ]
    then
       make_patch emane-model-lte
       make_patch srsRAN-emane
       make_patch opentestpoint-probe-lte
    fi
}

usage()
{
    echo
    echo " usage: adjacentlink-foss-build < build | clean >"
    echo
}


case "$1" in
    build)
        build_all
        ;;

    clean)
        clean_all
        ;;

    help)
        usage
        exit 0
        ;;

    *)
        usage
	exit 1
        ;;
esac
