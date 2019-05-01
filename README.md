# Interface errors and drops monitor check
Monitoring alert for high number of receive/transmit drops/errors

Usage:

`./interface_errors_and_drops_check.sh -t 60 -e 500 -c 1000`
* -t Seconds to wait between check
* -e Critical number of errors
* -c Critical number of drops
