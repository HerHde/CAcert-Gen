#!/bin/bash -i

while getopts ":d:" opt; do
  case $opt in
    d)
      echo "\".$OPTARG\" will be appended to the domain names." >&2
			TLD=".$OPTARG"
			shift $((OPTIND-1))
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
			exit 1
      ;;
  esac
done

mkdir -p _output
cd _output
for ARG in $*
do
    HOST=$ARG$TLD
    echo -e "\n=== DO $HOST:"
    mkdir -p $HOST
    cd $HOST
    
    # Config file gen
    cat <<EOF > openssl.cnf
# -------------- BEGIN custom openssl.cnf -----
 oid_section             = new_oids
 [ new_oids ]
 [ req ]
 default_days            = 730            # how long to certify for
 distinguished_name      = req_distinguished_name
 default_keyfile         = ${HOST}.key
 encrypt_key             = no
 string_mask = nombstr
 [ req_distinguished_name ]
 commonName              = Common Name (eg, YOUR name)lol
 commonName_default      = $HOST
# -------------- END custom openssl.cnf -----
EOF
    openssl req -new -batch -config openssl.cnf -newkey rsa:4096 -out $HOST.csr
	chmod 600 $HOST.key
    rm openssl.cnf
    echo -e "\n Copy the following Certificate Request and paste into CAcert website to obtain a Certificate."
    cat $HOST.csr
    
    echo "After pressing ENTER your editor will open up. Paste the certificate into it, save and exit."
    CRTCHK=1
    until [ $CRTCHK -eq 0 ]; do
	read
	/usr/bin/editor $HOST.crt
	openssl verify -CAfile ../root.crt $HOST.crt
	CRTCHK=$?
	if [ $CRTCHK -ne 0 ]
	  then
	    echo "Gooby, please reenter the *correct* certificate!"
	    echo "Hint: -----BEGIN CERTIFICATE-----"
	fi
    done

	chmod 644 $HOST.crt
    rm $HOST.csr
	ls -lA .
	cd ../
    echo "===DONE with $HOST"
done
