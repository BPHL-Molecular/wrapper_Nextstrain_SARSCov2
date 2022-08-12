#!/usr/bin/bash
#SBATCH --account=bphl-umbrella
#SBATCH --qos=bphl-umbrella
#SBATCH --job-name=test_nextstrain_covid19_full_database
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80                   
#SBATCH --mem=240gb
#SBATCH --time=48:00:00
#SBATCH --output=test_nextstrain_covid19_full_database.%j.out
#SBATCH --error=test_nextstrain_covid19_full_database.%j.err



python3 scripts/sanitize_sequences.py --sequences data/sequences_fasta_original.tar.xz --strip-prefixes "hCoV-19/" --output data/sequences_gisaid.fasta.gz

augur index \
    --sequences data/sequences_gisaid.fasta.gz \
    --output data/sequence_index_gisaid.tsv.gz
    
    
python3 scripts/sanitize_metadata.py \
    --metadata data/metadata_tsv_original.tar.xz \
    --database-id-columns "Accession ID" \
    --parse-location-field Location \
    --rename-fields 'Virus name=strain' 'Accession ID=gisaid_epi_isl' 'Collection date=date' \
    --strip-prefixes "hCoV-19/" \
    --output data/metadata_gisaid.tsv.gz

augur filter \
    --metadata data/metadata_gisaid.tsv.gz \
    --query "(country == 'USA') & (division == 'Washington')" \
    --min-date 2021-04-01 \
    --max-date 2021-06-01 \
    --exclude-ambiguous-dates-by any \
    --output-strains strains_washington.txt


augur filter \
    --metadata data/metadata_gisaid.tsv.gz \
    --query "(region == 'North America') & (division != 'Washington')" \
    --min-date 2021-04-01 \
    --max-date 2021-06-01 \
    --exclude-ambiguous-dates-by any \
    --subsample-max-sequences 1000 \
    --output-strains strains_north-america.txt
    
#augur filter \
    #--metadata data/metadata_gisaid.tsv.gz \
    #--query "region != 'North America'" \
    #--min-date 2020-12-01 \
    #--max-date 2021-06-01 \
    #--exclude-ambiguous-dates-by any \
    #--subsample-max-sequences 100 \
    #--group-by region year month \
    #--output-strains strains_global_100.txt

augur filter \
    --metadata data/metadata_gisaid.tsv.gz \
    --sequence-index data/sequence_index_gisaid.tsv.gz \
    --sequences data/sequences_gisaid.fasta.gz \
    --exclude-all \
    --include strains_washington.txt strains_north-america.txt \
    --output-metadata data/subsampled_metadata_gisaid.tsv.gz \
    --output-sequences data/subsampled_sequences_gisaid.fasta.gz


nextstrain build . --cores all --configfile select_config.yaml
