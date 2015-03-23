# Generator for SSL-Server-Certificates with CAcert
Create a SSL-Key, Certificate (and CSR) for webservers etc.

## Prequisites
You need:
* **openssl-client** installed
* An [CAcert](https://www.cacert.org/) Account with enough points to create server-certs with 24 months validity.
* The desired domain must be registered and accepted at CAcert.

## Usage
    ./gen.sh [-d TLD] SUB...
`SUB` are the desired domains, the optional `TLD` will be appended to each domain. The 4096 bit RSA-Key will be generated and its CSR (*Certificate Signing Request*) will be printed to the `STDOUT`. Copy and paste it into the [CAcert Form](https://secure.cacert.org/account.php?id=10) to receive the certificate.

**Hint:** *You may select SHA-512 as the hash-algorythm for improved security within the advanced options before sending the CSR.*

Copy and paste the certificate.

    -----BEGIN CERTIFICATE REQUEST-----
    [...]
    -----END CERTIFICATE REQUEST-----
Back in the terminal, press *ENTER*, *RETURN* or what the hell you might call it. Your favorite texteditor (defined with `update-alternatives --config editor`) will open up. Paste the cert, save and exit. The cert will be checked against the CAcert root cert. If the cert is correct, the whole procedure will begin with the next `SUB`.

The CSR will be deleted (you may regenerate it from the key if you are funny) and the other files will be `chmod`'ed as recommended.

## Afterwards
You will end up with a directory named by each domain (e.g. *sub.domain.tld*), containing
* *sub.domain.tld**.crt***, the actual certificate. It is *recommended* to give it `chmod 644` on the target system.
* *sub.domain.tld**.key***, the **privatekey**. You *should* keep it **private** and `chmod 600` it on the target system.
You may want to `scp` it to the actual server.
