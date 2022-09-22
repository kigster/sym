module Sym
  VERSION     = '3.0.2'
  DESCRIPTION = <<~eof

     Sym is a ruby library (gem) that offers both the command line interface 
     (CLI) and a set of rich Ruby APIs, which make it rather trivial to add 
     encryption and decryption of sensitive data to your development or deployment 
     workflow.
     
     For additional security the private key itself can be encrypted with a 
     user-generated password. For decryption using the key the password can be 
     input into STDIN, or be defined by an ENV variable, or an OS-X Keychain Entry. 
     
     Unlike many other existing encryption tools, Sym focuses on getting out of 
     your way by offering a streamlined interface with password caching (if 
     MemCached is installed and running locally) in hopes to make encryption of 
     application secrets nearly completely transparent to the developers. 
     
     Sym uses symmetric 256-bit key encryption with the AES-256-CBC cipher, 
     same cipher as used by the US Government. 
     
     For password-protecting the key Sym uses AES-128-CBC cipher. The resulting 
     data is zlib-compressed and base64-encoded. The keys are also base64 encoded 
     for easy copying/pasting/etc.
     
     Sym accomplishes encryption transparency by combining several convenient features:
      
       1. Sym can read the private key from multiple source types, such as pathname, 
          an environment variable name, a keychain entry, or CLI argument. You simply 
          pass either of these to the -k flag — one flag that works for all source types.
      
       2. By utilizing OS-X Keychain on a Mac, Sym offers truly secure way of 
          storing the key on a local machine, much more secure then storing it on a file system,
      
       3. By using a local password cache (activated with -c) via an in-memory provider 
          such as memcached, sym invocations take advantage of password cache, and 
          only ask for a password once per a configurable time period, 
     
       4. By using SYM_ARGS environment variable, where common flags can be saved. This 
          is activated with sym -A,
      
       5. By reading the key from the default key source file ~/.sym.key which 
          requires no flags at all,
      
       6. By utilizing the --negate option to quickly encrypt a regular file, or decrypt 
          an encrypted file with extension .enc
      
       7. By implementing the -t (edit) mode, that opens an encrypted file in your $EDITOR, 
          and replaces the encrypted version upon save & exit, optionally creating a backup.
      
       8. By offering the Sym::MagicFile ruby API to easily read encrypted files into memory.

    Please refer the module documentation available here:
    https://www.rubydoc.info/gems/sym
     
  eof
end
