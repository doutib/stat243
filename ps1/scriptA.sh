for i in 1965 1975 1985 1995 2005
do
	echo $i
	echo $(awk -F'[,]' '$4~'$i'' data_countries.txt | grep "Area Harvested" | sed 's/\"//g' | sort -t"," -k6 -n -r | head -n 5 | cut -d',' -f1)
done
