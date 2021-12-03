rule vep:
    input:
        vcf="analysis_output/{sample}/mutect2/{sample}.panel.{diagnosis}.vcf",
        fasta=config["reference"]["fasta"],
        cache=config["vep"]["cache"],
    output:
        "analysis_output/{sample}/vep/{sample}.panel.{diagnosis}.vcf",
    log: 
        "analysis_output/{sample}/vep/{sample}.panel.{diagnosis}.log",
    container:
        config["tools"]["vep"]
    threads: 4
    message:
        "{rule}: Annotate {wildcards.sample} vcf"
    shell:
        """
        (vep \
        --vcf \
        --no_stats \
        --fork {threads} \
        -i {input.vcf} \
        -o {output} \
        --fasta {input.fasta} \
        --dir_cache {input.cache} \
        --refseq \
        --offline \
        --cache \
        --everything) &> {log}
        """
