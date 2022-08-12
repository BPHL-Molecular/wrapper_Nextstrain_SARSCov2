#!/usr/bin/bash
#SBATCH --account=bphl-umbrella
#SBATCH --qos=bphl-umbrella
#SBATCH --job-name=test_nextstrain_covid19_full_database
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10                    #the setting number should be less than the max cpu limit(150). 
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
