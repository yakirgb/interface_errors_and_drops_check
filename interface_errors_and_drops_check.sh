#!/bin/bash
# Alert on high number of Receive/Transmit drops/errors
# The script taking the values from /proc/net/dev, waiting X time and check the diff.

# Example for /proc/net/dev
#[root@tim001 ~]# cat /proc/net/dev
# Inter-|   Receive                                                      | Transmit
#  face | bytes       packets  errs drop fifo frame compressed multicast | bytes       packets  errs drop fifo colls carrier compressed
#  bond0: 35660723789 44517181 0    0    0    0     0          0           41476342041 49947773 0    0    0    0     0       0
#   eth0: 35660726267 44517220 0    0    0    0     0          0           41476342041 49947773 0    0    0    0     0       0
#     lo: 288563383   1354387  0    0    0    0     0          0           288563383   1354387  0    0    0    0     0       0


function usage {
        cat <<-END >&2
        USAGE: `basename $0` {-t seconds | -e number of errors | -d number of drops} [interval [duration]]
                         -t # Seconds to wait between check
                         -e # Critical number of errors
                         -c # Critical number of drops
          eg,
               `basename $0` -t 60 -e 1000 -d 500
END
        exit
}

while getopts t:e:d:h opt
do
        case $opt in
        t)      slepp_time=$OPTARG ;;
        e)      critical_number_of_errors=$OPTARG ;;
        d)      critical_number_of_drops=$OPTARG ;;
        h|?)    usage ;;
        esac
done

# Functions to get current rx/tx errors/drops:
# Sum Receive/errs column
rx_errors () {
  cat /proc/net/dev | awk '{sum += $4} END {print sum}'
}

# Sum Transmit/errs columns
tx_errors () {
  cat /proc/net/dev | awk '{sum += $12} END {print sum}'
}

# Sum Receive/drop columns
rx_drops () {
  cat /proc/net/dev | awk '{sum += $5} END {print sum}'
}

# Sum Transmit/drop columns
tx_drops () {
  cat /proc/net/dev | awk '{sum += $13} END {print sum}'
}

# First result
rx_errors_first=$(rx_errors)
tx_errors_first=$(tx_errors)
rx_drops_first=$(rx_drops)
tx_drops_first=$(tx_drops)

# Sleep between checks
sleep $slepp_time

# Second result
rx_errors_second=$(rx_errors)
tx_errors_second=$(tx_errors)
rx_drops_second=$(rx_drops)
tx_drops_second=$(tx_drops)

# Get diff between results
rx_errors_result=$(expr $rx_errors_second - $rx_errors_first)
tx_errors_result=$(expr $tx_errors_second - $tx_errors_first)
rx_drops_result=$(expr $rx_drops_second - $rx_drops_first)
tx_drops_result=$(expr $tx_drops_second - $tx_drops_first)

if [ $rx_errors_result -ge $critical_number_of_errors ] || \
   [ $tx_errors_result -ge $critical_number_of_errors ] || \
   [ $rx_drops_result  -ge $critical_number_of_drops ] || \
   [ $tx_drops_result  -ge $critical_number_of_drops ]
then
echo "CRTICAL: RX errors: $rx_errors_result \
TX errors: $tx_errors_result \
RX drops: $rx_drops_result \
TX drops: $tx_drops_result"
exit 2
fi
