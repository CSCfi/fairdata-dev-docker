all: certs

certs:
	@test -f server.crt || openssl req -x509 -days 365 -nodes -subj '/C=FI/ST=Uusimaa/L=Espoo/O=CSC - Tieteen tietotekniikan keskus Oy/CN=ida.csc.local' -addext "subjectAltName = DNS:ida.csc.local" -addext "extendedKeyUsage = serverAuth" -newkey rsa:2048 -out server.crt -keyout server.pem
