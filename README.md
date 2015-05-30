# Generator for SSL-Server-Certificates with CAcert
Create a SSL-Key, Certificate (and CSR) for webservers etc.

## Prequisites
You need:
* **openssl-client** installed
* An [CAcert](https://www.cacert.org/) Account with enough points to create server-certs with 24 months validity.
* The desired domain must be registered and accepted at CAcert.

## Usage
    ./gen.sh [-c [1|3]] [-d TLD] HOST...
`HOST` are the desired domains, the optional `TLD` will be appended to each domain. The 4096 bit RSA-Key will be generated and its CSR (*Certificate Signing Request*) will be printed to the `STDOUT`. Copy and paste it into the [CAcert Form](https://secure.cacert.org/account.php?id=10) to receive the certificate.

**Hint:** *Within the web formular, you may select SHA-512 as the hash-algorythm for improved security within the advanced options before submitting the CSR.*

Copy and paste the certificate.

    -----BEGIN CERTIFICATE REQUEST-----
    [...]
    -----END CERTIFICATE REQUEST-----
Back in the terminal, press *ENTER*, *RETURN* or what the hell you might call it. Your favorite texteditor (defined with `update-alternatives --config editor`) will open up. Paste the cert, save and exit. The cert will be checked against the CAcert root cert. If the cert is correct, the whole procedure will begin with the next `HOST`.
If `HOST` is `.` or the same as `TLD`, `TLD` will also be used as a `HOST`.

With flag `-c` set, CAcert Class 1 (and Class 3, if the option is followed by `3`) PKI key will be cat'ed behind each certificate to build an entire *root certificate chain*.

The CSR will be deleted (you may regenerate it from the key if you are funny) and the other files will be `chmod`'ed as recommended.

## Afterwards
You will end up with a directory named by each domain (e.g. *./_output/sub.domain.tld*), containing
* *sub.domain.tld.crt*, the actual **certificate**. It is *recommended* to give it `chmod 644` on the target system.
* *sub.domain.tld.key*, the **privatekey**. You *should* keep it **private** and `chmod 600` it on the target system.
You may want to `scp` it to the actual server.

## License
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>. This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
