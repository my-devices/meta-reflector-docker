#! /bin/bash

openssl genrsa -out reflector.key 2048
openssl req -new -key reflector.key -out reflector.csr -config reflector.conf
openssl req -new -sha256 -key reflector.key -out reflector.csr -config reflector.conf
openssl req -x509 -nodes -sha256 -key reflector.key -in reflector.csr -out reflector.cer -config reflector.conf -extensions 'v3_req' -days 365
openssl x509 -noout -text -in reflector.cer
cat reflector.cer reflector.key >reflector.pem
