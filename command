cat ABSim100K_10000.A_B_refseq_sample.5.gsi | sed -e 's/AB_refseq.R/AB_refseq.R\t/g ; s/AB_refseq.L/AB_refseq.L\t/g ; s/@/00##/g ; s/#/0##/g ' | sort -k1,1 -k2n,2 -k3,3 | sed -e 's/AB_refseq.R\s/AB_refseq.R/g ; s/AB_refseq.L\s/AB_refseq.L/g ; s/00##/@/g ; s/0##/#/g' > ABSim100K_10000.A_B_refseq_sample.5.sorted.gsi 

cat ABSim100K_10000.A_B_refseq_sample.5.gsi | sed -e 's/AB_refseq.R/AB_refseq.R\t/g ; s/AB_refseq.L/AB_refseq.L\t/g ; s/@/00##/g ; s/#/0##/g ' | sort -k1,1 -k2n,2 -k3,3 | sed -e 's/AB_refseq.R\s/AB_refseq.R/g ; s/AB_refseq.L\s/AB_refseq.L/g ; s/00##/@/g s/0##/#/g' | ABSim100K_10000.A_B_refseq_sample.5.sorted.gsi

samtools view -h data/ABSim100K_10000.A_B_refseq_sample.dyara_rabema_taxo_1024.qname.bam | grep -v '\*\s0\s0\s\*' | samtools view -S -b > data/ABSim100K_10000.A_B_refseq_sample.dyara_rabema_taxo_1024.qname2.bam
