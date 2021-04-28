def get_fq(wildcards):
    if config["trimming"]["skip"]:
        # no trimming, use raw reads
        return units.loc[(wildcards.sample, wildcards.unit), ["fq1", "fq2"]].dropna()
    else:
        # yes trimming, use trimmed data
        if not is_single_end(**wildcards):
            # paired-end sample
            #print(expand("trimmed/{sample}-{unit}.{group}.fastq.gz", group=[1, 2], **wildcards))
            return expand("trimmed/{sample}-{unit}.{group}.fastq.gz", group=[1, 2], **wildcards)
        # single end sample
        #print("trimmed/{sample}-{unit}.fastq.gz".format(**wildcards))
        return "trimmed/{sample}-{unit}.fastq.gz".format(**wildcards)

def get_fq(wildcards):
    if not is_single_end(**wildcards):
        # paired-end sample
        #print(expand("trimmed/{sample}-{unit}.{group}.fastq.gz", group=[1, 2], **wildcards))
        return expand("trimmed/{sample}-{unit}.{group}.fastq.gz", group=[1, 2], **wildcards)
    # single end sample
    #print("trimmed/{sample}-{unit}.fastq.gz".format(**wildcards))
    return "trimmed/{sample}-{unit}.fastq.gz".format(**wildcards)

def get_trim_fastq1(wildcards):
    fq1 = expand("trimmed/{sample}-{unit}.1.fastq.gz", **wildcards)
    #print(fq1)
    return fq1

def get_trim_fastq2(wildcards):
    fq2 = expand("trimmed/{sample}-{unit}.2.fastq.gz", **wildcards)
    #print(fq2)
    return fq2

#rule star_index:
#    input:
#        fasta = config["ref"]["genomefa"],
#        gtf = config["ref"]["annotation"]
#    output:
#        directory(config["ref"]["index"])
#    threads:
#        12
#    params:
#        #needed to change params below to build xenopus index
#        extra = ""
#    log:
#        "logs/star_index_genome.log"
#    wrapper:
#        "0.71.1/bio/star/index"
            

rule hisat2_index:
    input:
        fasta = config["ref"]["genomefa"]
    output:
        directory("index_genome")
    params:
        prefix = "index_genome/"
    log:
        "logs/hisat2_index_genome.log"
    threads: 16
    wrapper:
        "0.73.0/bio/hisat2/index"

rule hisat2_align:
    input:
      #reads=[get_trim_fastq1, get_trim_fastq2]
      reads=get_fq
    output:
      "mapped/{sample}.{unit}.bam"
    log:
      "logs/hisat2/{sample}_{unit}.log"
    params:
      extra="--new-summary",
      idx="index_genome/",
    threads: 16
    wrapper:
      "0.73.0/bio/hisat2/align"

#rule symlink_bam:
#    input:
#        "star/{sample}-{unit}/Aligned.sortedByCoord.out.bam" 
#    output:
#        "star/{sample}-{unit}/{sample}-{unit}_Aligned.sortedByCoord.out.bam" 
#    threads: 1
#    shell:
#        """
#        ln -s Aligned.sortedByCoord.out.bam {output}
#        """

#rule mark_duplicates:
#    input:
#        "star/{sample}-{unit}/Aligned.sortedByCoord.out.bam"
#    output:
#        bam="dedup/{sample}-{unit}.bam",
#        metrics="dedup/{sample}-{unit}.metrics.txt"
#    log:
#        "logs/picard/dedup/{sample}-{unit}.log"
#    params:
#        "REMOVE_DUPLICATES=true"
#    # optional specification of memory usage of the JVM that snakemake will respect with global
#    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
#    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
#    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
#    resources:
#        mem_mb=1024
#    wrapper:
#        "0.71.1/bio/picard/markduplicates"
#
