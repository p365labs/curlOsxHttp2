#Curl OSX HTTP/2 support#

On OSX lastest versions of curl are only available through brew or 
with macport.

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
