#!/bin/bash
echo " como de grande quieres la piramide"
read piramide 

for((i=1; i<=piramide; i++))
do
  for((j=1; j<=i; j++))
  do
	random=$(( $RANDOM%99 ))

    echo -n "$random "
  done
  echo
done
