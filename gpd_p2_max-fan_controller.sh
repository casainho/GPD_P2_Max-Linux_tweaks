#!/bin/bash

TEMPERATURE_FAN_DISABLE=50
TEMPERATURE_FAN_LEVEL_1=55
TEMPERATURE_FAN_LEVEL_2=60
TEMPERATURE_FAN_LEVEL_3=65
TEMPERATURE_FAN_LEVEL_4=70

FAN_DISABLE=0xf1
FAN_LEVEL_1=0xf8
FAN_LEVEL_2=0xff
FAN_LEVEL_3=0xfa
FAN_LEVEL_4=0xfb

EC_READ_VALUE="$(sudo perl ec_control.pl ?= 0x70)"
echo "${EC_READ_VALUE}	"

if [ $EC_READ_VALUE -lt $TEMPERATURE_FAN_DISABLE ]
then
  echo "FAN_DISABLE"
  perl ec_control.pl := 0x31 $FAN_DISABLE
elif [ $EC_READ_VALUE -lt $TEMPERATURE_FAN_LEVEL_1 ]
then
  echo "FAN_LEVEL_1"
  perl ec_control.pl := 0x31 $FAN_LEVEL_1
elif [ $EC_READ_VALUE -lt $TEMPERATURE_FAN_LEVEL_2 ]
then
  echo "FAN_LEVEL_2"
  perl ec_control.pl := 0x31 $FAN_LEVEL_2
elif [ $EC_READ_VALUE -lt $TEMPERATURE_FAN_LEVEL_3 ]
then
  echo "FAN_LEVEL_3"
  perl ec_control.pl := 0x31 $FAN_LEVEL_3
else
  echo "FAN_LEVEL_4"
  perl ec_control.pl := 0x31 $FAN_LEVEL_4
fi


