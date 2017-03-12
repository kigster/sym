module Sym
  VERSION     = '2.6.1'
  DESCRIPTION = <<-eof
### Sym — Symmetric Encryption Made Easy
  
**Sym** is a ruby library (gem) that offers both the command line interface (CLI) and a set of rich Ruby APIs, which make it rather trivial to add encryption and decryption of sensitive data to your development or deployment flow. As a layer of additional security, you can encrypt the private key itself with a password. 

Unlike many other existing encryption tools, Sym focuses on getting out of the way — by offering its streamlined interface, hoping to make encryption of application secrets nearly completely transparent to the developers. 

For the data encryption Sym uses a symmetric 256-bit key with the `AES-256-CBC` cipher, same cipher as used by the US Government. For password-protecting the key Sym uses `AES-128-CBC` cipher. The resulting data is zlib-compressed and base64-encoded. The keys are also base64 encoded for easy copying/pasting/etc.
  
### Massive Time Savers

Sym accomplishes encryption transparency by combining convenience features:

 * Sym can read the private key from multiple source types, such as: a pathname to a file, an environment variable name, a keychain entry, or CLI argument. You simply pass either of these to the `-k` flag — one flag that works for all source types
 * By utilizing OS-X Keychain on a Mac, Sym offers truly secure way of storing the key on a local machine, much more secure then storing it on a file system
 * By using a local password cache (activated with `-c`) via an in-memory provider such as memcached or `drb`, sym invocations take advantage of password cache, and only ask for a password once per a configurable time period
 * By using `SYM_ARGS` environment variable, where common flags can be saved. This is activated with `sym -A`
 * By reading the key from the default key source file `~/.sym.key` which requires no flags at all
 * By utilizing the `--negate` option to quickly encrypt a regular file, or decrypt an encrypted file with extension `.enc`
 * By implementing the `-t` (edit) mode, that opens an encrypted file in your `$EDITOR`, and replaces the encrypted version upon save & exit, optionally creating a backup.
 * By offering the `Sym::MagicFile` ruby API to easily read encrypted files into memory.
  eof
end
