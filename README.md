# Generator for SSL-server-certificates with CAcert
Create a SSL-key, certificate (and CSR) for mail/webservers etc., trusted and signed by CAcert.org.

## Prequisites
You need:
* **openssl-client** installed (besides a [webbrowser](https://mozilla.org/firefox/) and some other pretty standard programs)
* A [CAcert](https://www.cacert.org/) account (with enough points to create server-certs with 24 months validity).
* The desired domain must be registered and accepted at CAcert.

## Usage
    ./gen.sh [-c [1|3]] [-d TLD] HOST...
`HOST` are the desired domains, the optional `TLD` will be appended to each domain. The 4096 bit RSA-key will be generated and its CSR (*Certificate Signing Request*) will be printed to the `STDOUT`. Copy and paste it into the [CAcert form](https://secure.cacert.org/account.php?id=10) to receive the certificate.

**Hint:** *Within the web formular, you may select SHA-512 as the hash-algorythm for improved security against hash collisions within the advanced options before submitting the CSR. However, some older implementations may not support it.*

Copy and paste the certificate.

    -----BEGIN CERTIFICATE REQUEST-----
    [...]
    -----END CERTIFICATE REQUEST-----

Back in the terminal, just paste the cert (into the `cat`), press *ENTER*, *RETURN* or what the hell you might call it to end with a empty line, and then `CTRL`+`D` or whatever `EOF` you can paste to exit. The cert will be checked against the CAcert root cert. If the cert is correct, the whole procedure will repeat with the next `HOST`.
If `HOST` is `.` or the same as `TLD`, `TLD` will also be used as a `HOST`.

With flag `-c` set, CAcert class 1 (and class 3, if the option is followed by `3`) PKI key will be cat'ed behind each certificate to build an entire *root certificate chain*.

The CSR will be deleted (you may regenerate it from the key if you are funny) and the other files will be `chmod`'ed as recommended.

## Afterwards
You will end up with a directory named by each domain (e.g. *./_output/sub.domain.tld*), containing
* *sub.domain.tld.crt*, the actual **certificate**. It is *recommended* to give it `chmod 644` on the target system.
* *sub.domain.tld.key*, the **privatekey**. You *should* keep it **private** and `chmod 600` it on the target system.
You may want to `scp` it to the actual server.

## License
Copyright/Copyleft/Copywrong (C) 2015 Henrik "HerHde" Hüttemann (admin@herh.de).

Hosted at https://chef.l-uni.co/technik/CAcert-Gen

License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>. This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
