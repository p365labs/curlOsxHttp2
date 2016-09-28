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
#
# Federico Panini, @p365labs
# https://github.com/p365labs/curlOsxHttp2
#
# Felix Schwarz, IOSPIRIT GmbH, @@felix_schwarz.
#   https://gist.github.com/c61c0f7d9ab60f53ebb0.git
# Bochun Bai
#   https://github.com/sinofool/build-libcurl-ios
# Jason Cox, @jasonacox
#   https://github.com/jasonacox/Build-OpenSSL-cURL 
# Preston Jennings
#   https://github.com/prestonj/Build-OpenSSL-cURL 

set -e

usage ()
{
	echo "usage: $0 [curl version] NGHTTP2=[where nghttp2 has been compiled]"
	exit 127
}

if [ "$1" == "-h" ]; then
	usage
fi

if [ -z $1 ]; then
	CURL_VERSION="curl-7.50.3"
else
	CURL_VERSION="curl-$1"
fi

DEVELOPER=`xcode-select -print-path`
IPHONEOS_DEPLOYMENT_TARGET="6.0"

# HTTP2 support
NOHTTP2="/tmp/no-http2"
if [ ! -f "$NOHTTP2" ]; then
	# nghttp2 will be in ../nghttp2/{Platform}/{arch}
	NGHTTP2="${PWD}/../nghttp2"  
fi

if [ ! -z "$NGHTTP2" ]; then 
	echo "Building with HTTP2 Support (nghttp2)"
else
	echo "Building without HTTP2 Support (nghttp2)"
	NGHTTP2CFG=""
	NGHTTP2LIB=""
fi

buildMac()
{
	ARCH=$1
	HOST="i386-apple-darwin"

	echo "Building ${CURL_VERSION} for ${ARCH}"

	TARGET="darwin-i386-cc"

	if [[ $ARCH == "x86_64" ]]; then
		TARGET="darwin64-x86_64-cc"
	fi

	if [ ! -z "$NGHTTP2" ]; then 
		NGHTTP2CFG="--with-nghttp2=${NGHTTP2}/Mac/${ARCH}"
		NGHTTP2LIB="-L${NGHTTP2}/Mac/${ARCH}/lib"
	fi

	export CC="${BUILD_TOOLS}/usr/bin/clang"
	export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -fembed-bitcode"
	export LDFLAGS="-arch ${ARCH} -L${OPENSSL}/Mac/lib ${NGHTTP2LIB}"
	pushd . > /dev/null
	cd "${CURL_VERSION}"
	./configure -prefix="/tmp/${CURL_VERSION}-${ARCH}" -disable-shared --enable-static -with-random=/dev/urandom --with-darwinssl ${NGHTTP2CFG} --host=${HOST} &> "/tmp/${CURL_VERSION}-${ARCH}.log"

	make -j8 >> "/tmp/${CURL_VERSION}-${ARCH}.log" 2>&1
	make install >> "/tmp/${CURL_VERSION}-${ARCH}.log" 2>&1
	# Save curl binary for Mac Version
	cp "/tmp/${CURL_VERSION}-${ARCH}/bin/curl" "/tmp/curl"
	make clean >> "/tmp/${CURL_VERSION}-${ARCH}.log" 2>&1
	popd > /dev/null
}

echo "Cleaning up"
rm -rf include/curl/* lib/*

mkdir -p lib
mkdir -p include/curl/

rm -rf "/tmp/${CURL_VERSION}-*"
rm -rf "/tmp/${CURL_VERSION}-*.log"

rm -rf "${CURL_VERSION}"

if [ ! -e ${CURL_VERSION}.tar.gz ]; then
	echo "Downloading ${CURL_VERSION}.tar.gz"
	curl -LO https://curl.haxx.se/download/${CURL_VERSION}.tar.gz
else
	echo "Using ${CURL_VERSION}.tar.gz"
fi

echo "Unpacking curl"
tar xfz "${CURL_VERSION}.tar.gz"

echo "Building Mac libraries"
buildMac "x86_64"

echo "Copying headers"
cp /tmp/${CURL_VERSION}-x86_64/include/curl/* include/curl/

lipo \
	"/tmp/${CURL_VERSION}-x86_64/lib/libcurl.a" \
	-create -output lib/libcurl_Mac.a

echo "Cleaning up"
cp /tmp/curl ~/curl
echo "curl has been moved to your home directory : $HOME/curl (type ~/curl --version)"
sleep 2
#rm -rf /tmp/${CURL_VERSION}-*
#rm -rf ${CURL_VERSION}

echo "Done"
