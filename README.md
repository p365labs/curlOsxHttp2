#Curl OSX HTTP/2 support#

##STILL IN PROGRESS - NOT FOR PRODUCTION## 

On OSX lastest versions of curl are only available through brew or 
with macport. 

If you want to have support for HTTP2 with **brew** you can do :

>install cURL with nghttp2 support

**brew install curl --with-nghttp2**

>link the formula to replace the system cURL

** brew link curl --force**

>now reload the shell
>test an HTTP/2 request passing the --http2 flag

**curl -I --http2 https://www.cloudflare.com/**

If you are using MacPorts is not so easy at all... the advice is to compile curl from source which should support **SSL** and **HTTP2**. In order to make curl support HTTP 2 protocol you need to install and compile **[NGGHTTP2](https://nghttp2.org/)** which is a library created to support it very well and which curl uses.

The shell script inside this repo will help OSX users to compile curl with SSL and HTTP2 support. inside these scripts we compile CURL with the **--with-darwinssl** flag which is supported by *iOS 5.0 or later, or OS X 10.5 ("Leopard") or later.*

When the Secure Transport (--with-darwinssl flag) is in use, the curl options --cacert and --capath and
their libcurl equivalents, will be *ignored*, because Secure Transport uses
the certificates stored in the **Keychain** to evaluate whether or not to trust
the server. This, of course, includes the root certificates that ship with
the OS. The --cert and --engine options, and their libcurl equivalents, are
currently unimplemented in curl with Secure Transport.

###Update OSX curl with the lastest version and setup http2 support###

inspired from [https://github.com/jasonacox/Build-OpenSSL-cURL](https://github.com/jasonacox/Build-OpenSSL-cURL)

*Build scripts to update OSX curl with http2 support*

**[directly from Curl documentation] (https://curl.haxx.se/docs/install.html):**

>On recent Apple operating systems, curl can be built to use Apple's
   SSL/TLS implementation, Secure Transport, instead of OpenSSL. To build with
   Secure Transport for SSL/TLS, use the configure option --with-darwinssl. (It
   is not necessary to use the option --without-ssl.) This feature requires iOS
   5.0 or later, or OS X 10.5 ("Leopard") or later.
 
>When Secure Transport is in use, the curl options --cacert and --capath and
   their libcurl equivalents, will be ignored, because Secure Transport uses
   the certificates stored in the Keychain to evaluate whether or not to trust
   the server. This, of course, includes the root certificates that ship with
   the OS. The --cert and --engine options, and their libcurl equivalents, are
   currently unimplemented in curl with Secure Transport.

##How to use it##

the script is packaged inside a set of bash scripts, u can freely use to build
a new **CURL** binary. After executing 
>build-all.sh

a new directory will be created inside the project : **archive**
inside you will find the new executable.

to check if the new **Curl** has HTTP2 support execute it with **--version**
if you see HTTP2 in the output the trick is done!

curl 7.50.3 (i386-apple-darwin) libcurl/7.50.3 SecureTransport zlib/1.2.8 nghttp2/1.14.0
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp smb smbs smtp smtps telnet tftp
Features: IPv6 Largefile NTLM NTLM_WB SSL libz **HTTP2** UnixSockets
