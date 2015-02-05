#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

BOARD_VENDOR="$(cat /sys/class/dmi/id/board_vendor)"
BOARD_NAME="$(cat /sys/class/dmi/id/board_name)"
BIOS_VERSION="$(cat /sys/class/dmi/id/bios_version)"

echo "NCT6776 fan configuration"
echo
echo "VENDOR: $BOARD_VENDOR"
echo "BOARD : $BOARD_NAME"
echo "BIOS  : $BIOS_VERSION"

REG=0
for RAWDATA in $(isadump -y -k 0x87,0x87 0x2e 0x2f 0x0b | egrep -A3 '^00:' | sed 's/^..: //'); do
  DATA="0x$RAWDATA"
  case "$REG" in
    28|36|39|44|48)
       echo
       printf 'R0x%02x : %s\n' $REG $DATA
       echo "-----------------------------------------------"
  esac
  case "$REG" in
    28)
       if (( DATA & 0x01 )); then
         printf 'R0x%02x : %s\n' $REG "AUXFANIN1 connected to Pin4"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANIN1 not connected"
       fi
       if (( DATA & 0x02 )); then
         printf 'R0x%02x : %s\n' $REG "AUXFANIN2 connected to Pin5"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANIN2 not connected"
       fi
       ;;
    36)
       if (( DATA & 0x20 )); then
         printf 'R0x%02x : %s\n' $REG "AUXFANIN0 connected to Pin3"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANIN0 not connected"
       fi
       if (( DATA & 0x10 )); then
         printf 'R0x%02x : %s\n' $REG "AUXFANOUT type Push-pull"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANOUT type Open-drain"
       fi
       if (( DATA & 0x08 )); then
         printf 'R0x%02x : %s\n' $REG "SYSFANOUT type Push-pull"
       else
         printf 'R0x%02x : %s\n' $REG "SYSFANOUT type Open-drain"
       fi
       if (( DATA & 0x04 )); then
         printf 'R0x%02x : %s\n' $REG "CPUFANOUT type Push-pull"
       else
         printf 'R0x%02x : %s\n' $REG "CPUFANOUT type Open-drain"
       fi
       ;;
    39)
       if (( DATA & 0x80 )); then
         printf 'R0x%02x : %s\n' $REG "GPIO7 symbols GP70-GP75 connected to Pin88-Pin93"
       else
         printf 'R0x%02x : %s\n' $REG "GPIO7 symbols GP70-GP75 not connected"
       fi
       if (( DATA & 0x40 )); then
         printf 'R0x%02x : %s\n' $REG "GPIO7 symbols GP76-GP77 connected to Pin86-Pin87"
       else
         printf 'R0x%02x : %s\n' $REG "GPIO7 symbols GP76-GP77 not connected"
       fi
       ;;
    44)
       if (( DATA & 0x80 )); then
         printf 'R0x%02x : %s\n' $REG "AUXFANOUT connected to Pin98 (PWM signal)"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANOUT not connected"
       fi
       ;;
    48)
       if (( DATA & 0x80 )); then
	       printf 'R0x%02x : %s\n' $REG "AUXFANIN0 connected to GPIO7 symbol GP70 (Pin93) "
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANIN0 connected to Pin3"
       fi
       if (( DATA & 0x40 )); then
	       printf 'R0x%02x : %s\n' $REG "AUXFANIN1 connected to GPIO7 symbol GP72 (Pin91)"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANIN1 connected to Pin4"
       fi
       if (( DATA & 0x20 )); then
	       printf 'R0x%02x : %s\n' $REG "AUXFANIN2 connected to GPIO7 symbol GP73 (Pin90)"
       else
         printf 'R0x%02x : %s\n' $REG "AUXFANIN2 connected to Pin5"
       fi
       ;;
  esac
  REG=$((REG + 1))
done

# dump all GPIO registers if requested
[ "$1" = "all" ] || exit 0

echo
echo "============================="
echo "RegDump Logical Device 7"
echo "============================="
REG=0
for RAWDATA in $(isadump -y -k 0x87,0x87 0x2e 0x2f 0x07 | egrep -A15 '^00:' | sed 's/^..: //'); do
  DATA="0x$RAWDATA"
  case "$REG" in
    48|224|225|226|227|228|229|230|231|232|233|234|235|236|237|238|244|245|246|247|248)
       printf 'R0x%02x : %s\n' $REG $DATA
  esac
  REG=$((REG + 1))
done

echo
echo "============================="
echo "RegDump Logical Device 8"
echo "============================="
REG=0
for RAWDATA in $(isadump -y -k 0x87,0x87 0x2e 0x2f 0x08 | egrep -A15 '^00:' | sed 's/^..: //'); do
  DATA="0x$RAWDATA"
  case "$REG" in
    48|96|97|224|225|226|227|228|240|241|242|243|244|245|246|247)
       printf 'R0x%02x : %s\n' $REG $DATA
  esac
  REG=$((REG + 1))
done

echo
echo "============================="
echo "RegDump Logical Device 9"
echo "============================="
REG=0
for RAWDATA in $(isadump -y -k 0x87,0x87 0x2e 0x2f 0x09 | egrep -A15 '^00:' | sed 's/^..: //'); do
  DATA="0x$RAWDATA"
  case "$REG" in
    48|224|225|226|227|228|229|230|231|233|234)
       printf 'R0x%02x : %s\n' $REG $DATA
  esac
  REG=$((REG + 1))
done
echo
echo "============================="
echo "RegDump Logical Device F"
echo "============================="
REG=0
for RAWDATA in $(isadump -y -k 0x87,0x87 0x2e 0x2f 0x0F | egrep -A15 '^00:' | sed 's/^..: //'); do
  DATA="0x$RAWDATA"
  if [ "$REG" -ge 224 ] && [ "$REG" -le 241 ]; then
    printf 'R0x%02x : %s\n' $REG $DATA
  fi
  REG=$((REG + 1))
done

echo
echo "============================="
echo "RegDump Logical Device 17"
echo "============================="
REG=0
for RAWDATA in $(isadump -y -k 0x87,0x87 0x2e 0x2f 0x17 | egrep -A15 '^00:' | sed 's/^..: //'); do
  DATA="0x$RAWDATA"
  case "$REG" in
    224|225|226|227|228|229)
       printf 'R0x%02x : %s\n' $REG $DATA
  esac
  REG=$((REG + 1))
done
