#!/usr/bin/env bash
#
# (C) Copyright 2019, Xilinx, Inc.
#
#!/usr/bin/env bash

install_libs(){
    #sudo apt install -y ocl-icd
    #sudo apt install -y ocl-icd-devel
    apt update
    apt install -y opencl-headers
    /proj/oct-fpga-p4-PG0/tools/Xilinx/Vitis/${VITISVERSION}/scripts/installLibs.sh
    bash -c "echo 'source /proj/octfpga-PG0/tools/Xilinx/Vitis/${VITISVERSION}/settings64.sh' >> /etc/profile"
}

install_xrt() {
    echo "Download XRT installation package"
    wget -cO - "https://www.xilinx.com/bin/public/openDownload?filename=$XRT_PACKAGE" > /tmp/$XRT_PACKAGE
    echo "Install XRT"
    echo "Ubuntu XRT install"
    echo "Installing XRT dependencies..."
    apt update
    echo "Installing XRT package..."
    apt install -y /tmp/$XRT_PACKAGE
    bash -c "echo 'source /opt/xilinx/xrt/setup.sh' >> /etc/profile"
}

check_xrt() {
    XRT_INSTALL_INFO=`apt list --installed 2>/dev/null | grep "xrt" | grep "$XRT_VERSION"`
}

install_xbflash() {
    cp -r /proj/oct-fpga-p4-PG0/tools/xbflash/${OSVERSION} /tmp
    echo "Installing xbflash"
    apt install /tmp/${OSVERSION}/*.deb
}

verify_install() {
    errors=0
    check_xrt
    if [ $? == 0 ] ; then
        echo "XRT installation verified."
    else
        echo "XRT installation could not be verified."
        errors=$((errors+1))
    fi
    return $errors
}
SHELL=1
OSVERSION=`grep '^ID=' /etc/os-release | awk -F= '{print $2}'`
OSVERSION=`echo $OSVERSION | tr -d '"'`
VERSION_ID=`grep '^VERSION_ID=' /etc/os-release | awk -F= '{print $2}'`
VERSION_ID=`echo $VERSION_ID | tr -d '"'`
OSVERSION="$OSVERSION-$VERSION_ID"
REMOTEDESKTOP=$1
XRTVERSION=$2
VITISVERSION=$3
SCRIPT_PATH=/local/repository
COMB="${XRTVERSION}_${OSVERSION}"
XRT_PACKAGE=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $1}' | awk -F= '{print $2}'`
XRT_VERSION=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $7}' | awk -F= '{print $2}'`
U280=1

install_libs
install_xrt
install_xbflash
    
if [ $? == 0 ] ; then
    echo "XRT installation successful."
else
    echo "XRT installation failed."
    exit 1
fi

echo "$REMOTEDESKTOP"
if [ $REMOTEDESKTOP == "True" ] ; then
    echo "Installing remote desktop software"
    apt install -y ubuntu-gnome-desktop
    echo "Installed gnome desktop"
    systemctl set-default multi-user.target
    apt install -y tigervnc-standalone-server
    echo "Installed vnc server"
fi

echo "Done running startup script."
exit 0
