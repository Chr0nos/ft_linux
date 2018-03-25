build() {
	curl -k https://curl.haxx.se/ca/cacert.pem | \
		awk '{print > "cert" (1+n) ".pem"} /-----END CERTIFICATE-----/ {n++}'
	c_rehash
}
