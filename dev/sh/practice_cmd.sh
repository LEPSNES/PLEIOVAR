
# View to top lines
head  ../data/vcf/uncompressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf | less -SN
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | less -SN
# Calculat freq
head  ../data/vcf/uncompressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf | vcftools --vcf - --freq
head  ../data/vcf/uncompressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf | vcftools --vcf - --counts
head  ../data/vcf/uncompressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf | vcftools --vcf - --depth

# Increase the number of open file descriptors, specific for each tty
ulimit -n 30000
# List limits
ulimit -a
# List hard limits
ulimit -Ha
head ../data/vcf/uncompressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf | vcftools --vcf - --012 --out head_matrix
# Output 012 matrix for one chrom
time zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | vcftools --vcf - --012 --out sample_file/chr21.smpl
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | vcftools --vcf - --remove-filtered-all --012 --out sample_file/chr21_filterAll.smpl
# Output 012 matrix in regions specified in a bed file
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr2.vcf.gz | vcftools --vcf - --bed ../data/gene/tst.bed --remove-filtered-all --012 --out tst/bed
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr2.vcf.gz | vcftools --vcf - --bed ../data/gene/tst.bed  --012 --out tst/bed_nofilter
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | vcftools --vcf - --bed ../data/gene/gene_by_chrom/chrom_21.bed --remove-filtered-all --012 --out tst/chrom_21_bed
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr11.vcf.gz | vcftools --vcf - --bed ../data/gene/gene_by_chrom/chrom_11.bed --remove-filtered-all --012 --out tst/chrom_11_bed
# Try providing bed values via pipe
# Provides bed values via pipe does not work
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | vcftools --vcf - --bed ../data/gene/gene_by_chrom/chrom_21.bed --remove-filtered-all --012 --out tst/chrom_21_bed
head ../data/gene/gene_by_chrom/chrom_21.bed | vcftools --gzvcf ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz  --bed - --remove-filtered-all --012 --out tst/chrom_21_bed-pipe
# Provide regions via from-bp and to-bp

zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | vcftools --vcf - --chr 21 --from-bp 1 --to-bp 100000000 --remove-filtered-all --012 --out tst/chrom_21_fromto



# Count column number
head -3 sample_file/chr21.smpl.012 | awk '{print NF}'
# Count frequency of FILTER column
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | head -1200 | awk '!/^#/{a[$7]++} END{for(x in a) print (x, a[x])}'
zcat ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz | awk '!/^#/{a[$7]++} END{for(x in a) print (x, a[x])}'

# Split genes by chroms
cat All_Genes_hg19 | awk '{print($0) >> "chrom_"$1".bed"}'
# Insert a title line
sed -i '1i chrom\tchromStart\tchromEnd\tgene' *.bed


# Parallel, split input string
parallel --colsep '-' echo {4} {3} {2} {1}  ::: A-B C-D ::: e-f g-h
parallel --colsep ' ' echo {4} {3} {2} {1}  ::: A B C D E
parallel --colsep '\s' echo {5} {4} {3} {2} {1}  ::: A B C D E
parallel --colsep '-' echo {5} {2} ::: A-B-C-D-E
parallel --csv --colsep=' ' echo {4} {3}   ::: A B C D E
echo -e "\"filename1\" \"some text 1\"\n\"filename2 withspaces\" \"some text   2\""| parallel --csv --colsep=' ' echo arg1:{1} arg2:{2}
echo -e  "file 1\ntext 1\nfile 2\ntext 2""file 1\ntext 1\nfile 2\ntext 2" | parallel --csv --colsep=' ' echo arg1:{1} arg2:{2}
echo -e  "file1 text1\nfile2 text2"\n"file 1\ntext 1\nfile 2\ntext 2" | parallel --csv --colsep=' ' echo arg1:{1} arg2:{2}
echo -e  "file1 text1\nfile2 text2"\n"file 1\ntext 1\nfile 2\ntext 2" | parallel --csv --colsep=' ' echo arg1:{1} arg2:{2}
echo "A B C D" | parallel --csv --colsep=' ' echo {1} {3}
head ../data/gene/gene_by_chrom/chrom_21.bed | parallel --csv --colsep=$'\t' echo arg1:{1} arg2:{2} {3} {4}
head ../data/gene/gene_by_chrom/chrom_21.bed | parallel --colsep=$'\t' echo arg1:{1} arg2:{2} {3} {4}
head ../data/gene/gene_by_chrom/chrom_21.bed | cut -d$'\t' -f1,2,3,4

# Use parellel, input source as bed file, column split

head ../data/gene/gene_by_chrom/chrom_21.bed | sed '1d' | parallel --colsep=$'\t' vcftools --gzvcf ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz  --chr {1} --from-bp {2} --to-bp {3} --remove-filtered-all --012 --out tst/chrom_21_bed_fromto_{4}
cat ../data/gene/gene_by_chrom/chrom_21.bed | sed '1d' | parallel --jobs 32 --colsep=$'\t' vcftools --gzvcf ../data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz  --chr {1} --from-bp {2} --to-bp {3} --remove-filtered-all --012 --out  variants_by_gene/chrom_21/{4}


# Install vcftools
# Follow the instructions at https://github.com/vcftools/vcftools
# Build from GitHub
git clone https://github.com/vcftools/vcftools.git
cd vcftools
./autogen.sh
./configure
make
sudo make install
# Test installation
which vcftools
vcftools --version
vcftools --help




