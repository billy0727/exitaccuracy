#! /bin/bash

# File: 
#    exacc.sh
# Program: 
#    Calculate Positive Predictive Value and Sensitivity to compare with MedicusTek
# History: 
#    2017/12/22 Billy First Release
# Note:
#    1. exec by bash.
#
#
# 

echo "" > temp.txt
echo "date" >> temp.txt
echo "TotalExit" >> temp.txt
echo "TotalNIB" >> temp.txt
echo "TruePositives"  >> temp.txt
echo "FalsePositives" >> temp.txt
echo "FalseNegative"  >> temp.txt
echo "PositivePredictiveValue" >> temp.txt
echo "Sensitivity" >> temp.txt

# Enter parameters
read -p "Mac: " mac
read -p "Month: " month
read -p "Date From: " from
read -p "Date To: " to


# read date(01~31) by file to array
date='./date.txt'
seq=1
while read line
do
	lines[$seq]=$line
	((seq++))
done < $date


TotalTruePositives=0
TotalFalsePositives=0
TotalFalseNegative=0
Countdate=0

for ((i=${from}; i<=${to}; i++))
do
  TotalExit=$(cat *.log |grep -a "${month}-${lines[$i]}" |grep -a -c "sendAlert_Socket(${mac}, 14,")
  TotalNIB=$(cat *.log |grep -a "${month}-${lines[$i]}" |grep -a -c "sendAlert_Socket(${mac}, 1,")

  #TruePositives = Ea+Na; (Ea=Exit with alarm, Na=NIB with alarm)
  TruePositives=$(cat *.log |grep -a "${month}-${lines[$i]}" |grep -a "sendAlert_Socket(${mac}, 1" |grep -a -A1 14, |grep -a -c 1,)
  TotalTruePositives=$((${TruePositives}+${TotalTruePositives}))

  #FalsePositives=Ea; (Exit without NIB)
  FalsePositives=$((${TotalExit}-${TruePositives}))
  TotalFalsePositives=$((${FalsePositives}+${TotalFalsePositives}))

  #FalseNegative=Na; (NIB without Exit before)
  FalseNegative=$((${TotalNIB}-${TruePositives}))
  TotalFalseNegative=$((${FalseNegative}+${TotalFalseNegative}))

  #Result
  PositivePredictiveValue=$(echo "scale=2; ${TruePositives}/$((${TruePositives}+${FalsePositives}))" | bc )
  Sensitivity=$(echo "scale=2; ${TruePositives}/$((${TruePositives}+${FalseNegative}))" | bc )

echo "${month}-${lines[$i]}" >> temp.txt
echo "${TotalExit}">> temp.txt
echo "${TotalNIB}">> temp.txt
echo "${TruePositives}">> temp.txt
echo "${FalsePositives}">> temp.txt
echo "${FalseNegative}" >> temp.txt
echo "${PositivePredictiveValue}" >> temp.txt
echo "${Sensitivity}" >> temp.txt

done

printf '%5s %9s %9s %13s %14s %13s %23s %11s \n' $(cat temp.txt)


# Final Result
AvgPositivePredictiveValue=$(echo "scale=2; ${TotalTruePositives}/$((${TotalTruePositives}+${TotalFalsePositives}))" | bc )
AvgSensitivity=$(echo "scale=2; ${TotalTruePositives}/$((${TotalTruePositives}+${TotalFalseNegative}))" | bc )
echo "${TotalTruePositives}" >temp.txt
echo "${TotalFalsePositives}" >>temp.txt
echo "${TotalFalseNegative}" >>temp.txt
echo "${AvgPositivePredictiveValue}" >>temp.txt
echo "${AvgSensitivity}" >> temp.txt
printf '%39s %14s %13s %23s %11s \n' $(cat temp.txt) 

