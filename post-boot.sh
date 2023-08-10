add_to_path(){
    bash -c "echo 'source /proj/octfpga-PG0/tools/Xilinx/Vitis/${VITISVERSION}/settings64.sh' >> /etc/profile"
    bash -c "echo 'source /opt/xilinx/xrt/setup.sh' >> /etc/profile"
}

install_libs(){
    #sudo apt install -y ocl-icd
    #sudo apt install -y ocl-icd-devel
    apt update
    apt install -y opencl-headers
    echo "Installing Vitis ${VITISVERSION} libraries"
    /proj/octfpga-PG0/tools/Xilinx/Vitis/${VITISVERSION}/scripts/installLibs.sh
}

install_dev_platform(){
    echo "Install dev platform"
    cp /proj/octfpga-PG0/tools/dev_platform/${XRTVERSION}/*.deb /tmp
    apt install /tmp/xilinx-u280*.deb
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
}

install_shellpkg() {
if [[ "$SHELL" == 1 ]]; then     
    install_u280_shell  
fi
}

check_shellpkg() {
    PACKAGE_INSTALL_INFO=`apt list --installed 2>/dev/null | grep "$PACKAGE_NAME" | grep "$PACKAGE_VERSION"`
}

check_xrt() {
    XRT_INSTALL_INFO=`apt list --installed 2>/dev/null | grep "xrt" | grep "$XRT_VERSION"`
}

install_u280_shell() {
    check_shellpkg
    if [[ $? != 0 ]]; then
        echo "Download Shell package"
        wget -cO - "https://www.xilinx.com/bin/public/openDownload?filename=$SHELL_PACKAGE" > /tmp/$SHELL_PACKAGE
        if [[ $SHELL_PACKAGE == *.tar.gz ]]; then
            echo "Untar the package. "
            tar xzvf /tmp/$SHELL_PACKAGE -C /tmp/
            rm /tmp/$SHELL_PACKAGE
        fi
        echo "Install Shell"
        echo "Install Ubuntu shell package"
        apt-get install -y /tmp/xilinx*
        rm /tmp/xilinx*
    else
        echo "The package is already installed. "
    fi
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
    check_shellpkg
    if [ $? == 0 ] ; then
        echo "Shell package installation verified."
    else
        echo "Shell package installation could not be verified."
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
SHELL_PACKAGE=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $2}' | awk -F= '{print $2}'`
PACKAGE_NAME=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $5}' | awk -F= '{print $2}'`
PACKAGE_VERSION=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $6}' | awk -F= '{print $2}'`
XRT_VERSION=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $7}' | awk -F= '{print $2}'`
U280=1

install_libs
install_xrt
install_shellpkg
verify_install
add_to_path
    
if [ $? == 0 ] ; then
    echo "XRT and shell package installation successful."
else
    echo "XRT and/or shell package installation failed."
    exit 1
fi

install_dev_platform

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
