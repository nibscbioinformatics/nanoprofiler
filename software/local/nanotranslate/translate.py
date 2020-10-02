#This is a script to take input fastq data from FLASH and translate it with biopython
#Input data is in files like:
#/usr/share/sequencing/projects/317/alignments/317-D1-Bst3_S1_L001.relabel.fastq
#Then the translation needs to run from ATGGCACAG (MAQ) up to ACCGTCTCCTCA (TVSS)
#Note that most merged reads start as: CCGGCCATGGCACAG

import Bio
from Bio.Seq import Seq
import sys

filein = open(sys.argv[1])
fileout = open(sys.argv[2], "w")

startseq = "ATGGCACAG"
endseq = "ACCGTCTCCTCA"

readsread = 0
readspassing = 0

linecounter = 0
for line in filein:
  linecounter += 1
  if linecounter % 4 == 1:
    readsread += 1
    headerline = line
  if linecounter % 4 == 2:
    dna = Seq(line.rstrip())
    startbase = dna.find(startseq)
    endbase = dna.find(endseq)
    if startbase == -1 or endbase == -1: #read fails if missing the start or end sequence
      continue
    targetregion = Seq(line.rstrip()[startbase:endbase+1+len(endseq)])
    if len(str(targetregion)) % 3 != 0: #read fails if the grabbed region is not a multiple of three
      continue
    translated = targetregion.translate()
    if "*" in str(translated): #read fails if it has a stop codon
      continue
    readspassing += 1
    fileout.write(headerline)
    fileout.write(str(translated)+"\n")

print("Completed reading reads:")
print(readsread)
print("Of which passing and written into FASTA:")
print(readspassing)
