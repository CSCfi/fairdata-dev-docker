all:

certs:
	@test -f server.crt || openssl req -x509 -days 365 -nodes -subj '/C=FI/ST=Uusimaa/L=Espoo/O=CSC - Tieteen tietotekniikan keskus Oy/CN=etsin.csc.local' -addext "subjectAltName = DNS:etsin.csc.local" -addext "extendedKeyUsage = serverAuth" -newkey rsa:2048 -out server.crt -keyout server.pem
	@test -f redirect-server.crt || openssl req -x509 -days 365 -nodes -subj '/C=FI/ST=Uusimaa/L=Espoo/O=CSC - Tieteen tietotekniikan keskus Oy/CN=etsin.csc.local' -addext "subjectAltName = DNS:etsin.csc.local" -addext "extendedKeyUsage = serverAuth" -newkey rsa:2048 -out redirect-server.crt -keyout redirect-server.pem
