#/bin/bash
for s in n1deploy amazon-fiat gandi-ddk ddk; do
  echo "*** server $s ***"
  ssh $s './upgrdate.sh; sudo reboot' &
done

#echo '*** server arialocal ***'
#ssh arialocal './upgrdate.sh' &

echo '*** localhost ***'
~/upgrdate.sh
