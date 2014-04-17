# this program will import a FASTA file
# transcribe the sequence and output into a new file

f = open('fasta.txt', 'r')
header = f.readline()
sequence = f.readline()
RNAseq = sequence.replace("T", "U")

f.close()
RNAfile = ''
newfile1 = open('RNAfile', 'w')
newfile1.write(RNAseq)

newfile1.close()

