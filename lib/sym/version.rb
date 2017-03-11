module Sym
  VERSION = '2.5.3'
  DESCRIPTION = <<-eof
    Sym is a command line utility plus a straightforward Ruby API that makes it easy to 
    transparently handle sensitive data such as application secrets using symmetric
    encryption with a 256bit key.
 
    Unlike many modern encryption tools, sym focuses on the streamlined interface (CLI),
    and offers many time-saving features that make encryption/decryption of application
    secrets and other sensitive data as seamless as possible.   
 
    You can encrypt the key itself with a password, for an additional layer of security.
    You can choose to save the key to OS-X Keychain, making it difficult to get the key
    when only disk is accessible. Using memcached or DRb sym can cache passwords so that
    you don't have to retype it too often. Finally, the -t flag (edit mode) decrypts
    the file on the fly, and lets you edit the unencrypted contents in $EDITOR. 

    Sym can read the key from many sources, including file, environment variable, 
    keychain, or CLI argument — all of the above become arguments of -k flag: one 
    flag to define the key no matter where it lives.

    Finally, set environment variable SYM_ARGS to common flags you use, and then
    have sym read these flags, activating this time-saving feature with -A flag.     
     
    Sym uses a symmetric aes-256-cbc cipher with a private key and an IV vector, 
    and is built atop of OpenSSL.
  eof
end
