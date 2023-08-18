#!/bin/bash -
#
# Copyright (c) 2022-2023 - Adjacent Link LLC, Bridgewater, New Jersey
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

with_build_rpm=1
with_clean=1

app_name=$(basename $0)

kernel_release=$(uname -r)

if [ $# == 1 ]
then
    kernel_release=$1
fi

kernel_rpm_version=$(echo $kernel_release -r | awk -F \- '{print $1}')

kernel_release_no_arch=${kernel_release%.$(arch)}

kernel_src_version=${kernel_rpm_version%\.0}

rpm_release=$(echo $kernel_release -r | awk -F \- '{print $2}' | awk -F \. '{print $1}')

kernel_major_version=$(echo $kernel_rpm_version | awk -F \- '{print $1}' | awk -F \. '{print $1}')

kernel_src=linux-$kernel_src_version.tar.xz

cwd=$(pwd)

if [ ! -f $kernel_src ]
then
    wget https://mirrors.edge.kernel.org/pub/linux/kernel/v${kernel_major_version}.x/$kernel_src

    if [ $? -ne 0 ]
    then
        echo "$app_name abort: unable to download $kernel_src"
        exit 1
    fi
fi

if [ ! -d linux-$kernel_src_version ]
then
    echo "$app_name: building batman-adv module"
    
    tar xf $kernel_src

    if [ $? -ne 0 ]
    then
        echo "$app_name abort: unable to unroll $kernel_src"
        exit 1
    fi
fi

pushd linux-$kernel_src_version/net/batman-adv

echo "$app_name: building batman-adv module"

make \
    -C /lib/modules/$(uname -r)/build \
    M=$(pwd) \
    CFLAGS_MODULE="-DCONFIG_BATMAN_ADV_NC \
                   -DCONFIG_BATMAN_ADV_DAT \
                   -DCONFIG_BATMAN_ADV_BLA \
                   -DCONFIG_BATMAN_ADV_BATMAN_V" \
    CONFIG_BATMAN_ADV=m \
    CONFIG_BATMAN_ADV_BATMAN_V=y \
    CONFIG_BATMAN_ADV_BLA=y \
    CONFIG_BATMAN_ADV_DAT=y \
    CONFIG_BATMAN_ADV_NC=y

if [ $? -ne 0 ]
then
    echo "$app_name abort: unable to build batman-adv module"
    exit 1
fi

if [ $with_build_rpm -eq 1 ]
then
    echo "$app_name: building batman-adv kmod rpm"
    
    mkdir -p .rpmbuild/BUILD \
          .rpmbuild/SPECS \
          .rpmbuild/SOURCES \
          .rpmbuild/SRPMS \
          .rpmbuild/RPMS/noarch \
          .rpmbuild/tmp

    cat <<EOF > .rpmbuild/SPECS/batman.spec
%define source_date_epoch_from_changelog 0

Name: kmod-batman-adv-$kernel_release
Version: $kernel_src_version
Release: 1%{?dist}
License: GPLv2 and Redistributable, no modification permitted
Requires: kernel-core == $kernel_release_no_arch
BuildRequires: kernel-devel == $kernel_release_no_arch
Summary: batman-adv kernel module for $kernel_release

%description
This package provides the batman-adv kernel modules built for the Linux
kernel $kenrel_release for the x86_64 family of processors.

%install
mkdir -p \${RPM_BUILD_ROOT}/lib/modules/$kernel_release/extra/batman-adv
cp $(pwd)/batman-adv.ko \${RPM_BUILD_ROOT}/lib/modules/$kernel_release/extra/batman-adv

%post
/usr/sbin/depmod -a $kernel_release

%postun
/usr/sbin/depmod -a $kernel_release

%files
%defattr(-,root,root,-)
/lib/modules/$kernel_release/extra/batman-adv/*

EOF

    rpmbuild --clean -ba .rpmbuild/SPECS/batman.spec \
             --define "_topdir $(pwd)/.rpmbuild" \
             --define "_tmppath $(pwd)/.rpmbuild/tmp"

    if [ $? -ne 0 ]
    then
        echo "$app_name abort: unable to build batman-adv rpm"
        exit 1
    fi
    
    find .rpmbuild -name "*.rpm" -exec cp {} $cwd \;

    if [ $with_clean -eq 1 ]
    then
        rm -rf .rpmbuild
    fi
fi

popd

if [ $with_clean -eq 1 ]
then
    rm -rf linux-$kernel_src_version
fi

echo
echo
echo "To sign the kernel module after rpm install (secure boot):"
echo
echo "sudo /usr/src/kernels/$kernel_release/scripts/sign-file \\"
echo "  sha256 \\"
echo "  /path/to/your/mok.priv \\"
echo "  /path/to/your/mok.der \\"
echo "  /lib/modules/$kernel_release/extra/batman-adv/batman-adv.ko"
echo 
