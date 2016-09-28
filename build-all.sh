#!/bin/bash

# This script builds openssl+libcurl libraries for the Mac (just for MAC)
# if u need theese libs for Ios or iOS and tvOS please
# checkout : https://github.com/jasonacox/Build-OpenSSL-cURL
#
# Federico Panini, @p365labs
# https://github.com/p365labs/curlOsxHttp2
#
# Jason Cox, @jasonacox
#   https://github.com/jasonacox/Build-OpenSSL-cURL
#

########################################
# EDIT this section to Select Versions #
########################################

LIBCURL="7.50.3"
NGHTTP2="1.14.0"

########################################

# HTTP2 Support?
NOHTTP2="/tmp/no-http2"
rm -f $NOHTTP2

usage ()
{
        echo "usage: $0 [-disable-http2]"
        exit 127
}

if [ "$1" == "-h" ]; then
        usage
fi

if [ "$1" == "-disable-http2" ]; then
	touch "$NOHTTP2"
	NGHTTP2="NONE"	
else 
	echo "Building nghttp2 for HTTP2 support"
	cd nghttp2
	./ngbuild.sh "$NGHTTP2"
	cd ..
fi

echo
echo "Building Curl"
cd curl
./install-curl.sh "$LIBCURL" NGHTTP2=build/nghttp2/Mac/x86_64/
cd ..

echo 
echo "Libraries..."
echo
ARCHIVE="archive/libcurl-$LIBCURL-nghttp2-$NGHTTP2"
echo "Creating archive in $ARCHIVE..."
mkdir -p "$ARCHIVE"
cp curl/lib/*.a $ARCHIVE
cp nghttp2/lib/*.a $ARCHIVE
echo "Archiving Mac binaries for curl..."
mv /tmp/curl $ARCHIVE
$ARCHIVE/curl -V

rm -f $NOHTTP2
