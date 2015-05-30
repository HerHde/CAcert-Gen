#!/bin/bash -i
CAT=0
TLD=""
while :
do
    case "$1" in
      -d | --domain)
        TLD="$2" && echo "--domain: \"."$TLD\" "will be appended to the domain names." >&2
        shift 2
      ;;
      -h | --help)
        echo "Hilf dir selbst, dann hilft dir Gott." >&2 # display_help  # Call your function
        # no shifting needed here, we're done.
        exit 0
      ;;
      -c | --cat)
        case "$2" in
            3)
                CAT=$(cat root.crt class3.crt) && echo "--cat: CAcert class 1 & 3 PKI certificates will be chained to each certificate." >&2
                shift
            ;;
            1)
                CAT=$(cat root.crt) && echo "--cat: CAcert class 1 PKI certificate will be chained to each certificate." >&2
                shift
            ;;
            *)
                CAT=$(cat root.crt) && echo "--cat: CAcert class 1 PKI certificate will be chained to each certificate." >&2
            ;;
        esac
        shift
      ;; # End of cat
      --) # End of all options
        shift
        break
        ;;
      -*)
        echo "Error: Invalid option: $1" >&2
        exit 1
      ;;
      *)  # No more options
        break
      ;;
    esac
done


mkdir -p _output
cd _output
for ARG in $*
do
  if [ "$TLD" ]; then # If --domain is set
      if [ "$ARG" == "." ] || [ "$ARG" == "$TLD" ]; then # If Hostname is = --domain
          HOST=$TLD
      else
          HOST=$ARG"."$TLD
      fi
  else # Else (if HOST=FQND)
      HOST=$ARG
  fi
  echo -e "\n=== DO $HOST:"
  mkdir $HOST 2>/dev/null
  if [ $? -ne 0 ]; then
    while true; do
      read -p "A folder named $HOST already exists. Do you want to overwrite its content? (y/N): " yn
      case $yn in
        [Yy]* ) break;;
        * ) echo "Will not overwrite. Exiting."; exit; break;;
      esac
    done
  fi


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
commonName              = Common Name (eg, YOUR name)
commonName_default      = $HOST
# -------------- END custom openssl.cnf -----
EOF
  openssl req -new -batch -config openssl.cnf -newkey rsa:4096 -out $HOST.csr
  chmod 600 $HOST.key
  rm openssl.cnf
  echo -e "\n Copy the following Certificate Request and paste it into the CAcert webformular to obtain a Certificate."
  cat $HOST.csr

  echo "After pressing ENTER your editor will open up. Paste the certificate into it, save and exit."
  CRTCHK=1
  until [ $CRTCHK -eq 0 ]; do
    read
    /usr/bin/editor $HOST.crt
    sed -i -e '$a\' $HOST.crt
    openssl verify -CAfile ../../root.crt $HOST.crt
    CRTCHK=$?
    if [ $CRTCHK -ne 0 ]; then
      echo "Gooby, please reenter the *correct* certificate!"
      echo "Hint: -----BEGIN CERTIFICATE-----"
      echo "" > $HOST.crt
    fi
  done

  if [ "$CAT" != 0 ]; then
      echo "$CAT" >> $HOST.crt
  fi
  chmod 644 $HOST.crt
  rm $HOST.csr
  ls -lA .
  cd ../
  echo "=== DONE with $HOST"
done
