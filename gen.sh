#!/bin/bash -i
unset opt_cat opt_tld opt_san host_name domain_name domain_names san certcheck
while :
do
    case "$1" in
      -d | --domain)
        opt_tld="$2" && echo "--domain: \"."$opt_tld\" "will be appended to the domain names." >&2
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
                opt_cat=$(cat root.crt class3.crt) && echo "--cat: CAcert class 1 & 3 PKI certificates will be chained to each certificate." >&2
                shift
            ;;
            1)
                opt_cat=$(cat root.crt) && echo "--cat: CAcert class 1 PKI certificate will be chained to each certificate." >&2
                shift
            ;;
            *)
                opt_cat=$(cat root.crt) && echo "--cat: CAcert class 1 PKI certificate will be chained to each certificate." >&2
            ;;
        esac
        shift
      ;; # End of cat
      -s | --san)
        opt_san=true && echo "--san: First option will be used as the Common Name, all further are handled as SubjectAltNames." >&2
        shift 1
      ;;
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

if [[ $opt_san ]]; then
    domain_names=$1
    shift 1
    san=($*)
else
    domain_names=$*
fi

for domain_name in $domain_names
do
  if [ "$opt_tld" ]; then # If --domain is set
      if [ "$domain_name" == "." ] || [ "$domain_name" == "$opt_tld" ]; then # If Hostname is = --domain
          host_name=$opt_tld
      else
          host_name=$domain_name"."$opt_tld
      fi
  else # Else (if host_name=FQND)
      host_name=$domain_name
  fi
  echo -e "\n=== DO $host_name:"

  if [ $san ]; then
    echo -n "SANs"
    printf    '\t%s\n' "${san[@]}"
  fi
  echo

  mkdir $host_name 2>/dev/null
  if [ $? -ne 0 ]; then
    while true; do
      read -p "A folder named $host_name already exists. Do you want to overwrite its content? (y/N): " yn
      case $yn in
        [Yy]* ) break;;
        * ) echo "Will not overwrite. Exiting."; exit; break;;
      esac
    done
  fi

  cd $host_name

  # Config file gen
  cat <<EOF > openssl.cnf
oid_section             = new_oids
[ new_oids ]
[ req ]
#SAN#req_extensions          = v3_req
default_days            = 730
distinguished_name      = req_distinguished_name
default_keyfile         = ${host_name}.key
encrypt_key             = no
string_mask             = nombstr
[ req_distinguished_name ]
commonName              = Common Name (eg, YOUR name)
commonName_default      = $host_name
#SAN#[ v3_req ]
#SAN#basicConstraints        = CA:FALSE
#SAN#keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
#SAN#subjectAltName          = @alt_names
#SAN#[alt_names]
EOF

  if [ $san ]; then
    sed -e s/#SAN#//g -i openssl.cnf
    for i in "${!san[@]}"
    do
        echo "DNS.$((i+1)) = ${san[i]}" >> openssl.cnf
    done
  fi

  openssl req -new -batch -config openssl.cnf -newkey rsa:4096 -out $host_name.csr
  chmod 600 $host_name.key
  echo -e "\n Copy the following Certificate Request and paste it into the CAcert webformular to obtain a Certificate."
  cat $host_name.csr

  echo "Copy the certificate shown on the Website, paste it here and press CTRL + D to send an end-of-file."
  certcheck=1
  until [ $certcheck -eq 0 ]; do
    cat > $host_name.crt
    sed -i -n '/^-----BEGIN CERTIFICATE-----/,$p' $host_name.crt # Delete anything before the BEGIN-line.
    sed -i '/-----END CERTIFICATE-----/q' $host_name.crt # Delete anything after the END-line.
    # sed -i -e '$a\' $host_name.crt
    openssl verify -CAfile ../../root.crt $host_name.crt
    certcheck=$?
    if [ $certcheck -ne 0 ]; then
      echo "Gooby, please reenter the *correct* certificate!"
      echo "Hint: -----BEGIN CERTIFICATE-----"
    fi
  done

  if [ "$opt_cat" != 0 ]; then
      echo "$opt_cat" >> $host_name.crt
  fi
  chmod 644 $host_name.crt
  rm openssl.cnf
  rm $host_name.csr
  ls -lA .
  cd ../
  echo "=== DONE with $host_name"
  unset host_name
done
unset opt_cat opt_tld opt_san host_name domain_name domain_names san certcheck
