#!/usr/bin/env bash
#
# (C) Copyright 2019, Xilinx, Inc.
#
#!/usr/bin/env bash

install_xrt() {
    echo "Download XRT installation package"
    wget -cO - "https://www.xilinx.com/bin/public/openDownload?filename=$XRT_PACKAGE" > /tmp/$XRT_PACKAGE
    
    echo "Install XRT"
    if [[ "$OSVERSION" == "ubuntu-16.04" ]] || [[ "$OSVERSION" == "ubuntu-18.04" ]] || [[ "$OSVERSION" == "ubuntu-20.04" ]]; then
        echo "Ubuntu XRT install"
        echo "Installing XRT dependencies..."
        apt update
        echo "Installing XRT package..."
        apt install -y /tmp/$XRT_PACKAGE
    elif [[ "$OSVERSION" == "centos-7" ]] ; then
        echo "CentOS 7 XRT install"
        echo "Installing XRT dependencies..."
        yum install -y epel-release
        echo "Installing XRT package..."
        yum install -y /tmp/$XRT_PACKAGE
    elif [[ "$OSVERSION" == "centos-8" ]]; then
        echo "CentOS 8 XRT install"
        echo "Installing XRT dependencies..."
        #sudo yum remove -y xrt
        yum config-manager --set-enabled powertools
        yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        yum config-manager --set-enabled appstream
        echo "Installing XRT package..."
        sudo yum install -y /tmp/$XRT_PACKAGE
    fi
    sudo bash -c "echo 'source /opt/xilinx/xrt/setup.sh' >> /etc/profile"
}

install_shellpkg() {
if [[ "$SHELL" == 1 ]]; then     
    install_u280_shell  
fi
}

check_shellpkg() {
    if [[ "$OSVERSION" == "ubuntu-16.04" ]] || [[ "$OSVERSION" == "ubuntu-18.04" ]] || [[ "$OSVERSION" == "ubuntu-20.04" ]]; then
        PACKAGE_INSTALL_INFO=`apt list --installed 2>/dev/null | grep "$PACKAGE_NAME" | grep "$PACKAGE_VERSION"`
    elif [[ "$OSVERSION" == "centos-7" ]] || [[ "$OSVERSION" == "centos-8" ]]; then
        PACKAGE_INSTALL_INFO=`yum list installed 2>/dev/null | grep "$PACKAGE_NAME" | grep "$PACKAGE_VERSION"`
    fi
}

check_xrt() {
    if [[ "$OSVERSION" == "ubuntu-16.04" ]] || [[ "$OSVERSION" == "ubuntu-18.04" ]] || [[ "$OSVERSION" == "ubuntu-20.04" ]]; then
        XRT_INSTALL_INFO=`apt list --installed 2>/dev/null | grep "xrt" | grep "$XRT_VERSION"`
    elif [[ "$OSVERSION" == "centos-7" ]] || [[ "$OSVERSION" == "centos-8" ]]; then
        XRT_INSTALL_INFO=`yum list installed 2>/dev/null | grep "xrt" | grep "$XRT_VERSION"`
    fi
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
        if [[ "$OSVERSION" == "ubuntu-16.04" ]] || [[ "$OSVERSION" == "ubuntu-18.04" ]] || [[ "$OSVERSION" == "ubuntu-20.04" ]]; then
            echo "Install Ubuntu shell package"
            apt-get install -y /tmp/xilinx*
        elif [[ "$OSVERSION" == "centos-7" ]] || [[ "$OSVERSION" == "centos-8" ]]; then
            echo "Install CentOS shell package"
            yum install -y /tmp/xilinx*
        fi
        rm /tmp/xilinx*
        #if [[ -f /tmp/$SHELL_PACKAGE ]]; then rm /tmp/$SHELL_PACKAGE; fi
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
TOOLVERSION=$1
SCRIPT_PATH=/local/repository
COMB="${TOOLVERSION}_${OSVERSION}"
XRT_PACKAGE=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $1}' | awk -F= '{print $2}'`
SHELL_PACKAGE=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $2}' | awk -F= '{print $2}'`
DSA=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $3}' | awk -F= '{print $2}'`
PACKAGE_NAME=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $5}' | awk -F= '{print $2}'`
PACKAGE_VERSION=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $6}' | awk -F= '{print $2}'`
XRT_VERSION=`grep ^$COMB: $SCRIPT_PATH/spec.txt | awk -F':' '{print $2}' | awk -F';' '{print $7}' | awk -F= '{print $2}'`
U280=1

install_xrt
install_shellpkg
verify_install
    
if [ $? == 0 ] ; then
    echo "XRT and shell package installation successful."
else
    echo "XRT and/or shell package installation failed."
    exit 1
fi
echo "Done running startup script."
exit 0
