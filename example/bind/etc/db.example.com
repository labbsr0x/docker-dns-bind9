;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	example.com. root.example.com. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	example.com.
@	IN	A	127.0.0.1
@	IN	AAAA	::1
number1				A       12.34.56.78
number2				A       12.34.78.56
