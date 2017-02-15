module Sym
  VERSION = '2.2.1'
  DESCRIPTION = <<-eof
    Sym is a command line utility and a Ruby API that makes it trivial to encrypt and decrypt 
    sensitive data. Unlike many other existing encryption tools, sym focuses on usability and 
    streamlined interface (CLI), with the goal of making encryption easy and transparent. 
    The result? There is no excuse for keeping your application secrets unencrypted :)

    You can password-protect the key for an additional layer of security, and store the key in the  
    OS-X keychain. Use the key to reliably encrypt, decrypt and re-encrypt your application 
    secrets. Use the -t CLI switch to transparently edit an encrypted file in an editor of your choice.
 
    Sym uses a symmetric aes-256-cbc cipher with a private key and an IV vector.
  eof
end
