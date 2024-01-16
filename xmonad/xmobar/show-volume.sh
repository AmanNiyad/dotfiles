#!/bin/bash

VOL=$(pactl get-sink-volume 0 | awk '{print $3}')
declare -i const=6529

declare -i BARS=$(( VOL / const))

case $BARS in
    0)  echo "<fc=#cccccc>[mute]</fc>";;
    1)  echo "<fc=#00aa3c>󰝤              </fc>";;
    2)  echo "<fc=#00993c>󰝤󰝤             </fc>";;
    3)  echo "<fc=#10893c>󰝤󰝤󰝤            </fc>";;
    4)  echo "<fc=#01883c>󰝤󰝤󰝤󰝤           </fc>";;
    5)  echo "<fc=#11783c>󰝤󰝤󰝤󰝤󰝤          </fc>";;
    6)  echo "<fc=#11773c>󰝤󰝤󰝤󰝤󰝤󰝤         </fc>";;
    7)  echo "<fc=#21673c>󰝤󰝤󰝤󰝤󰝤󰝤󰝤        </fc>";;
    8)  echo "<fc=#12663c>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤       </fc>";;
    9)  echo "<fc=#22563c>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤      </fc>";;
    10) echo "<fc=#22553c>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤     </fc>";;
    11) echo "<fc=#33443c>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤    </fc>";;
    12) echo "<fc=#44333c>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤   </fc>";;
    13) echo "<fc=#55222b>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤  </fc>";;
    14) echo "<fc=#66111a>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤 </fc>";;
    *)  echo "<fc=#770009>󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤</fc>";;
esac
