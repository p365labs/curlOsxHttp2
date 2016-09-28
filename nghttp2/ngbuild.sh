#!/bin/bash
# This script downlaods and builds the Macnghttp2 libraries 
#
# this script is a simplified version of the one here :
# https://github.com/jasonacox/Build-OpenSSL-cURL
#
# but uses --with-darwinssl instead of OpenSSL
#
# directly from Curl documentation (https://curl.haxx.se/docs/install.html)
#   On recent Apple operating systems, curl can be built to use Apple's
#   SSL/TLS implementation, Secure Transport, instead of OpenSSL. To build with
#   Secure Transport for SSL/TLS, use the configure option --with-darwinssl. (It
#   is not necessary to use the option --without-ssl.) This feature requires iOS
#   5.0 or later, or OS X 10.5 ("Leopard") or later.
# 
#   When Secure Transport is in use, the curl options --cacert and --capath and
#   their libcurl equivalents, will be ignored, because Secure Transport uses
#   the certificates stored in the Keychain to evaluate whether or not to trust
#   the server. This, of course, includes the root certificates that ship with
#   the OS. The --cert and --engine options, and their libcurl equivalents, are
#   currently unimplemented in curl with Secure Transport.
#
# Credits:
# Federico Panini, @p365labs
# https://github.com/p365labs/curlOsxHttp2
#
# Jason Cox, @jasonacox
#   https://github.com/jasonacox/Build-OpenSSL-cURL 
#
# NGHTTP2 - https://github.com/nghttp2/nghttp2
#

# > nghttp2 is an implementation of HTTP/2 and its header 
# > compression algorithm HPACK in C
# 
# NOTE: pkg-config is required
 
set -e

usage ()
{
	echo "usage: $0 [nghttp2 version]"
	exit 127
}

if [ "$1" == "-h" ]; then
	usage
fi

if [ -z $1 ]; then
	NGHTTP2_VERNUM="1.14.0"
else
	NGHTTP2_VERNUM="$1"
fi

if [ -z $2 ]; then
	PKGCONFIG_VERNUM="0.29"
else
	PKGCONFIG_VERNUM="$2"
fi

# --- Edit this to update version ---

NGHTTP2_VERSION="nghttp2-${NGHTTP2_VERNUM}"
DEVELOPER=`xcode-select -print-path`

NGHTTP2="${PWD}/../nghttp2"

# Check to see if pkg-config is already installed
if (type "pkg-config" > /dev/null) ; then
	echo "pkg-config installed"
else
	echo "ERROR: pkg-config not installed... attempting to install."

	if [ ! -e ${NGHTTP2_VERSION}.tar.gz ]; then
		echo "Download lastest pkg-config version ${PKGCONFIG_VERNUM}"
		curl -LO https://pkg-config.freedesktop.org/releases/pkg-config-${PKGCONFIG_VERNUM}.tar.gz
	else
		echo "Using pkg-config-${PKGCONFIG_VERNUM}.tar.gz"
	fi

	echo "Unpacking pkg-config"
	tar xfz pkg-config-${PKGCONFIG_VERNUM}.tar.gz 

	echo
	echo "configure, compile and Install PKG-Config"
	echo

	cd pkg-config-${PKGCONFIG_VERNUM}
	./configure &> "/tmp/pkg-config-${PKGCONFIG_VERNUM}.log"


	make >> "/tmp/pkg-config-${PKGCONFIG_VERNUM}.log" 2>&1
	sudo make install >> "/tmp/pkg-config-${PKGCONFIG_VERNUM}.log" 2>&1
	make clean >> "/tmp/pkg-config-${PKGCONFIG_VERNUM}.log" 2>&1

	# Check to see if installation worked
	if (type "pkg-config" > /dev/null) ; then
		echo "SUCCESS: pkg-config installed"
	else
		echo "FATAL ERROR: pkg-config failed to install - exiting."
		exit
	fi
fi 

buildMac()
{
	ARCH=$1
        HOST="i386-apple-darwin"

	echo "Building ${NGHTTP2_VERSION} for ${ARCH}"

	TARGET="darwin-i386-cc"

	if [[ $ARCH == "x86_64" ]]; then
		TARGET="darwin64-x86_64-cc"
	fi

	export CC="${BUILD_TOOLS}/usr/bin/clang -fembed-bitcode"
        export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -fembed-bitcode"
        export LDFLAGS="-arch ${ARCH}"

	pushd . > /dev/null
	cd "${NGHTTP2_VERSION}"
	./configure --disable-shared --disable-app --disable-threads --enable-lib-only --prefix="${NGHTTP2}/Mac/${ARCH}" --host=${HOST} &> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log"
	make >> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log" 2>&1
	make install >> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log" 2>&1
	make clean >> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log" 2>&1
	popd > /dev/null
}

echo "Cleaning up"
rm -rf include/nghttp2/* lib/*
rm -fr Mac
rm -fr iOS
rm -fr tvOS

mkdir -p lib

rm -rf "/tmp/${NGHTTP2_VERSION}-*"
rm -rf "/tmp/${NGHTTP2_VERSION}-*.log"

rm -rf "${NGHTTP2_VERSION}"

if [ ! -e ${NGHTTP2_VERSION}.tar.gz ]; then
	echo "Downloading ${NGHTTP2_VERSION}.tar.gz"
	curl -LO https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERNUM}/${NGHTTP2_VERSION}.tar.gz
else
	echo "Using ${NGHTTP2_VERSION}.tar.gz"
fi

echo "Unpacking nghttp2"
tar xfz "${NGHTTP2_VERSION}.tar.gz"

echo "Building Mac libraries"
buildMac "x86_64"

lipo \
        "${NGHTTP2}/Mac/x86_64/lib/libnghttp2.a" \
        -create -output "${NGHTTP2}/lib/libnghttp2_Mac.a"

echo "Update build dir with NGHTTP2 compiled lib"
if [ ! -e ../build ]; then
	mkdir -p  ../build/nghttp2
fi
cp -rf ./Mac ../build/nghttp2/Mac

echo "Cleaning up"
rm -rf /tmp/${NGHTTP2_VERSION}-*
rm -rf ${NGHTTP2_VERSION}
echo "remove dir created at compile time"
rm -rf ./Mac
rm -rf ./lib
echo "Remove downloaded nghttp2 sources"
rm "${NGHTTP2_VERSION}.tar.gz"
if [ -e pkg-config-${PKGCONFIG_VERNUM} ]; then
	rm pkg-config-${PKGCONFIG_VERNUM}.tar.gz
	rm -rf "pkg-config-${PKGCONFIG_VERNUM}"
fi


echo "Done"
