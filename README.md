
# Data download

To save memory and resources on the boqueron cluster, I decided to download the information on my local computer. I did have issues downloading this data using wget. Either the process would become interrupted or there were some files that would become corrupt during download. 

```
wget https://sra-pub-src-1.s3.amazonaws.com/SRR30335016/20240308_Scerevisiae_duplex_004_pod5.tar.gz.1 
```

I did try to install sra tools to use `prefetch` and `fasterq dump`, but my conda environment is old. I shall try again some other time and will just use what I was able to download using `wget`. 


# Basecalling

We are interested in using `dorado basecaller`. Firstly, the dorado software needs fastq files as input. The files that I downloaded via `wget` are pod5 files so I need to convert these. I used pod5 to do just that. Afterwards, I tested both dorado and guppy basecalling followed by nanoplot analysis.

## Preparing for basecalling

### Installing pod5 software

pod5 is not a conda package so I’ll need to install pip to my environment, `basecalling_tools`, first:

```
conda install pip
```

```
pip install pod5
```

### Converting pod5 files to fastq files

```
pod5 convert fast5 fast5/ -o pod5/
```

## Dorado basecaller


### Installing dorado basecaller

At first, I did think that I would be able to use the GPU mode of dorado because my computer does support GPUs. So I started basecalling using dorado.

In a conda environment on my local computer I run the following:

```
curl "https://cdn.oxfordnanoportal.com/software/analysis/dorado-1.4.0-osx-arm64.zip" -o dorado-1.4.0-osx-arm64.tar.gz
```

Added the dorado path to my bashrc file:

```
# >>> Added by Judy Mar 23 for basecalling with dorado>>>
export PATH="$HOME/Downloads/dorado-1.4.0-osx-arm64/bin:$PATH"
# <<< Added by Judt Mar 23 for basecalling with dorado <<<
```

```
source ~/.bashrc
```

### Basecalling with dorado

To test out how different models would influence basecalling results, I evaluate different basecaller commands. dorado basecaller can identify the type of molecular information there is in the fastq files. I tested both fast and hac models for dorado with trim and no-trim parameters. I even tested specifying the the RNA sequencing kit that was used. Additionally, I tested the guppy basecaller model. To evaluate the basecalling results among these, I used nanoplots and looked at specific categories such as mean read length, mean read quality, total reads, total bases, and read length N50. 

```
##### dorado fast
dorado basecaller fast pod5/ --emit-fastq --device cpu > reads_dorado_rna_trim.fastq
# Nanoplot before filter and trimming
NanoPlot --prefix proj2_ --fastq reads_dorado_rna_trim.fastq --N50 --threads 32
```

```
##### dorado fast no-trim
dorado basecaller fast pod5/ --emit-fastq --no-trim --device cpu > reads_dorado_no-trim.fastq
NanoPlot --prefix proj2_ --fastq reads_dorado_no-trim.fastq --N50 --threads 32
```

```
##### dorado hac no-trim
dorado basecaller hac pod5/ --emit-fastq --no-trim --device cpu > reads_hac_no-trim.fastq
NanoPlot --prefix proj2_ --fastq reads_hac_no-trim.fastq --N50 --threads 32
```

```
########## dorado hac rna trim
dorado basecaller hac pod5/ --emit-fastq --device cpu > reads_hac_rna_trim.fastq
```

```
# specifying rna kit
dorado download --models-directory models/
dorado basecaller models/rna004_130bps_fast@v5.3.0 pod5/ --emit-fastq --device cpu --estimate-poly-a > reads_fast_rna_r9.4.1_trim.fastq 
```

### Basecalling with guppy

```
# guppy basecaller
guppy_basecaller -i fast5/ -s guppy_rna_fastq/ --config rna_r9.4.1_70bps_hac.cfg -r --num_callers 1 --cpu_threads_per_caller 32
# concatenate fastq files
cat guppy_rna_fastq/*fastq > guppy_rna.fastq
# run nanoplots
NanoPlot --prefix proj2_ --fastq guppy_rna.fastq --N50 --threads 32
```

Below you will notice the basecalling summaries from nanoplots and the runtime summaries of each command.

#### Basecalling Summary

| Basecaller                              | Mean Read Length | Mean Read Quality | Total Reads | Total Bases | Read Length N50 |
|----------------------------------------|------------------|-------------------|------------|-------------|-----------------|
| guppy (rna_r9.4.1_70bps_hac.cfg)       | 467              | 9.1               | 43,973     | 20,535,500  | 1,278           |
| dorado (fast, rna trim, cpu)           | 462.6            | 10                | 45,156     | 20,888,155  | 1,188           |
| dorado (fast, no-trim, cpu)            | 462.6            | 10                | 45,156     | 20,888,357  | 1,188           |
| dorado (hac, rna trim, cpu)            | 477.2            | 11                | 45,175     | 21,556,194  | 1,224           |
| dorado (hac, no-trim, cpu)             | 477.2            | 11                | 45,175     | 21,556,282  | 1,224           |

Since there is not a dramatic difference among these commands and parameters, I decided to go with the dorado hac, no-trim, cpu command.


For those scientists who are curious on runtimes, I have also prepared a runtime table.

#### Runtime Summary

| Basecaller                              | Runtime    | Start                     | End                       |
|----------------------------------------|------------|---------------------------|---------------------------|
| guppy (rna_r9.4.1_70bps_hac.cfg)       | 01:51:33   | N/A                       | N/A                       |
| dorado (fast, rna trim, cpu)           | N/A        | 2026-03-24 09:06:27.027   | 2026-03-24 10:19:51.134   |
| dorado (fast, no-trim, cpu)            | N/A        | 2026-03-24 11:12:53.351   | 2026-03-24 12:22:11.266   |
| dorado (hac, rna trim, cpu)            | 05:22:54   | 2026-03-26 11:47:33.354   | 2026-03-26 17:10:26.938   |
| dorado (hac, no-trim, cpu)             | 04:47:33   | 2026-03-25 18:13:29.524   | 2026-03-25 23:01:01.144   |


### Perform quality control using Filtlong to filter low quality reads

If you noticed, I am not going to use a trimming tool like porechop. I assumed that if there was not a difference among the nanoplots when using or not using the parameters no-trim that maybe these files have already been trimmed. Additionally, it was not completely clear to me whether porechop can be adequately used on ONT RNA sequencing reads (something I should oduble check), so I continued my pipeline with filtlong.

The following commands were used on boqueron cluster:

```
filtlong --min_mean_q 93 --min_length 3000 reads_hac_rna_trim.fastq > reads_hac_rna_trim_filtlong.fastq
NanoPlot --prefix proj2_ --fastq reads_hac_rna_trim_filtlong.fastq --N50 --threads 32
```

Since using 3000 as the min_length was very aggressive, I tested lower numbers and evaluated results using nanoplot.

```
# min_length = 1000
filtlong --min_mean_q 93 --min_length 1000 reads_hac_rna_trim.fastq > reads_hac_rna_trim_filtlong_q93_len1K.fastq 
NanoPlot --prefix proj2_ --fastq reads_hac_rna_trim_filtlong_q93_len1K.fastq --N50 --threads 32
```

```
# min_length = 900
filtlong --min_mean_q 93 --min_length 900 reads_hac_rna_trim.fastq > reads_hac_rna_trim_filtlong_q93_len900.fastq 
NanoPlot --prefix proj2_ --fastq reads_hac_rna_trim_filtlong_q93_len900.fastq --N50 --threads 32
```

```
# min_length = 850
filtlong --min_mean_q 93 --min_length 850 reads_hac_rna_trim.fastq > reads_hac_rna_trim_filtlong_q93_len850.fastq 
NanoPlot --prefix proj2_ --fastq reads_hac_rna_trim_filtlong_q93_len850.fastq --N50 --threads 32
```

```
# min_length = 500
filtlong --min_mean_q 93 --min_length 500 reads_hac_rna_trim.fastq > reads_hac_rna_trim_filtlong_q93_len500.fastq 
NanoPlot --prefix proj2_ --fastq reads_hac_rna_trim_filtlong_q93_len500.fastq --N50 --threads 32
```

## Read Filtering Summary (by Minimum Length)

| Min Length | Mean Read Length | Mean Read Quality | Total Reads | Total Bases | Read Length N50 |
|------------|------------------|-------------------|-------------|-------------|-----------------|
| 3000       | 3,322.8          | 12.6              | 519         | 1,724,510   | 3,350           |
| 1000       | 1,968.1          | 12.6              | 3,728       | 7,337,077   | 2,143           |
| 900        | 1,890.5          | 12.6              | 4,035       | 7,628,283   | 2,089           |
| 850        | 1,846.3          | 12.6              | 4,219       | 7,789,365   | 2,061           |
| 500        | 1,466.5          | 12.7              | 6,170       | 9,048,378   | 1,838           |


Using 900 might be the happy medium here.









