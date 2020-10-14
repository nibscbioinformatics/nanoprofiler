#This is a script to go through a CD-HIT clusters output file and for each entry like
#@R7
#MAQVRLVESGGGLAQAGGSLRLSCEASGFTSDDWAIGWFRQAPGKEREGVSCIRHSTQTTAYADSVKGRFNISGDSAKNTVYLQMNSLKPKDTAVYYCAALILFMGTYYDPIDLLGYEYENWGQGIQVTVSS
#Extract the CDR3 sequence and write it out in a file in fasta format
#The CDR3 begins with amino acids which commence after a YYC and terminates with the amino acids which precede a WGQ
#Skip any CDR3 sequence that has already been encountered, and write out total unique CDR3s at the end
#Also make a histogram of lengths of these CDR3s
# UPDATE - the script also outputs a tsv file with all CDR3 even if not unique: this is to be used later

import sys
import Bio
from Bio.Seq import Seq
## from Bio.Alphabet import generic_dna ##not used anymore in biopython
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="cdhit clusters file",
                    action="store", dest = "input")
parser.add_argument("-c", "--cdr", help="output unique CDR3 fasta file",
                    action="store", dest = "cdr")
parser.add_argument("-t", "--tsv", help="output all CDR3 TSV file",
                    action="store", dest = "tsv")                    
parser.add_argument("-o", "--hist", help="output histogram file",
                    action="store", dest = "hist")
args = parser.parse_args()

bigset = set()

preseq = "YYC"
postseq = "WGQ"

filein = open(args.input)
fileout = open(args.cdr, "w")
tsvfile = open(args.tsv, "w")
histo = open(args.hist, "w")

tsvfile.write("ID\tCDR3\tunique\n")

linecount = 0
for line in filein:
  linecount += 1
  if linecount % 2 == 1:
    header = line.rstrip()
    fastaheader = header.replace("@",">")
    identifier = header.replace("@", "")
  else:
    sequence = Seq(line.rstrip())
    startaa = sequence.find(preseq) + 3
    endaa = sequence.find(postseq)
    if startaa == -1 or endaa == -1:
      continue
    targetbit = line.rstrip()[startaa:endaa]
    if targetbit in bigset or len(targetbit) > 50 or len(targetbit) < 1:
      tsvfile.write(identifier + "\t" + targetbit + "\t" + "non-unique\n")
      continue
    bigset.add(targetbit)
    fileout.write(fastaheader + "\n")
    fileout.write(targetbit + "\n")
    tsvfile.write(identifier + "\t" + targetbit + "\t" + "non-unique\n")

filein.close()
fileout.close()

#print("Got total number of CDR3s: "+str(len(bigset)))

bighist = {}
for i in range(51):
  bighist[i] = 0
for sequence in bigset:
  bighist[len(sequence)] += 1
histo.write("Size,Count")
for i in range(51):
  histo.write(str(i) + "," + str(bighist[i]) + "\n")
