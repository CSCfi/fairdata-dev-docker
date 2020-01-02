all: openssl-OpenSSL_1_1_1d
	cd openssl-OpenSSL_1_1_1d && mkdir -p $(PWD)/build
	cd openssl-OpenSSL_1_1_1d && ./config shared --openssldir=$(PWD)/build --prefix=$(PWD)/build
	cd openssl-OpenSSL_1_1_1d && make
	cd openssl-OpenSSL_1_1_1d && make install

openssl-OpenSSL_1_1_1d: OpenSSL_1_1_1d.tar.gz
	tar xvf OpenSSL_1_1_1d.tar.gz

OpenSSL_1_1_1d.tar.gz:
	curl -LO https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz

clean:
	-rm OpenSSL_1_1_1d.tar.gz
	-rm -Rf openssl-OpenSSL_1_1_1d
