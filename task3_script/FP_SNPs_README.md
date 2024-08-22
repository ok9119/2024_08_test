**---ЗАДАЧА 3---**

Алгоритм предобработки файла FP_snps.txt содержится в csp3_preprocess_fin.sh

```
# Узнаем, под какими номерами столбцы с нужными названиями
chrom_col=$(awk -v RS='\t' '/chromosome/{printf NR; exit}' $(pwd)/FP_SNPs.txt)
pos_col=$(awk -v RS='\t' '/GB38_position/{printf NR; exit}' $(pwd)/FP_SNPs.txt)
dbsnp_col=$(awk -v RS='\t' '/rs#/{printf NR; exit}' $(pwd)/FP_SNPs.txt)
allele1_col=$(awk -v RS='\t' '/allele1/{printf NR; exit}' $(pwd)/FP_SNPs.txt)
allele2_col=$(awk -v RS='\t' '/allele2/{printf NR; exit}' $(pwd)/FP_SNPs.txt)

# Сохраняем их в заданном порядке, опуская ненужные (позиция по GRCh37) 
awk -v chrom_col=$chrom_col -v pos_col=$pos_col -v dbsnp_col=$dbsnp_col -v allele1_col=$allele1_col -v allele2_col=$allele2_col \
	'BEGIN {FS="\t"; OFS="\t"} {print $chrom_col, $pos_col, $dbsnp_col, $allele1_col, $allele2_col}' \
	$(pwd)/FP_SNPs.txt > $(pwd)/FP_SNPs_OUT.txt

# Переименовываем 1 строки нескольких столбцов
awk 'NR==1{$1="#CHROM"}1' $(pwd)/FP_SNPs_OUT.txt  > $(pwd)/FP_SNPs_OUT2.txt
awk 'NR==1{$2="POS"}2' $(pwd)/FP_SNPs_OUT2.txt > $(pwd)/FP_SNPs_OUT.txt
awk 'NR==1{$3="ID"}3' $(pwd)/FP_SNPs_OUT.txt > $(pwd)/FP_SNPs_OUT2.txt

# Добавляем префиксы 
awk 'NR>1{ $1="chr" $1; } 1' < $(pwd)/FP_SNPs_OUT2.txt > $(pwd)/FP_SNPs_OUT.txt
awk 'NR>1{ $3="rs" $3; } 3' < $(pwd)/FP_SNPs_OUT.txt > $(pwd)/FP_SNPs_OUT2.txt

# Удаляем хромосому X
awk -v OFS='\t' '{ if ($1!="chr23"); print $1, $2, $3, $4, $5}' $(pwd)/FP_SNPs_OUT2.txt > $(pwd)/FP_SNPs_10k_GB38_twoAllelsFormat.tsv
```
В результате остается 10 тыс. строк со снипами.

Основной скрипт предствален в 2 вариантах, отличие которых заключается в том, какие файлы используются в качестве референса.
csp3_sep_chrom_ref.py - отдельные fasta-файлы для каждой хромосомы на основе GRCh38.d1.vd1
csp3_single_ref.py - распакованный и проиндексированный GRCh38.d1.vd1

В качестве аргументов при запуске в командной строке скрипты принимают путь к входному файлу, путь к папке для выходных файлов, путь к геному.
Аргументы не прописаны как обязательные в argparse, так как иначе некорректно работал запуск справки, однако существование указанных фалов/ путей проверяется на следующем после объявления этих аргументов шаге.

Затем предусмотрена проверка корректности имен столбцов.

С помощью метода класса FastaFile fetchпо координатам снипов в геноме находим референсный вариант. Поскольку из-за маскирования некоторые нуклеотиды записаны в fasta в нижнем регистре, для корректности последующего сравнения с аллелями1 и 2 переводим их в верхний регистр.

Затем проверяем, совпадает ли референсный вариант с одним из аллелей и в новом столбце в качестве альтернативы указываем тот, который с ним не совпал.

Лог выполнения в файле log.txt

**Готовый файл с распознанными аллелями находится в FP_SNPs_10k_GB38_REF_ALT_RES.tsv**
