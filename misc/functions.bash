
# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}";
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
	local port="${1:-4000}";
	local ip=$(ipconfig getifaddr en1);
	sleep 1 && open "http://${ip}:${port}/" &
	php -S "${ip}:${port}";
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript;
	else # pipe
		python -mjson.tool | pygmentize -l javascript;
	fi;
}

# Run `dig` and display the most useful info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# UTF-8-encode a string of Unicode symbols
function escape() {
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
	perl -e "binmode(STDOUT, ':utf8'); print \"$@\"";
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Get a character’s Unicode code point
function codepoint() {
	perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))";
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
# function getcertnames() {
# 	if [ -z "${1}" ]; then
# 		echo "ERROR: No domain specified.";
# 		return 1;
# 	fi;
#
# 	local domain="${1}";
# 	echo "Testing ${domain}…";
# 	echo ""; # newline
#
# 	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
# 		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);
#
# 	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
# 		local certText=$(echo "${tmp}" \
# 			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
# 			no_serial, no_sigdump, no_signame, no_validity, no_version");
# 		echo "Common Name:";
# 		echo ""; # newline
# 		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
# 		echo ""; # newline
# 		echo "Subject Alternative Name(s):";
# 		echo ""; # newline
# 		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
# 			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
# 		return 0;
# 	else
# 		echo "ERROR: Certificate not found.";
# 		return 1;
# 	fi;
# }
