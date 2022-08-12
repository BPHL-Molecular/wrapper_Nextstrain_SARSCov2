#!/usr/bin/bash
#SBATCH --account=bphl-umbrella
#SBATCH --qos=bphl-umbrella
#SBATCH --job-name=nextstrain_covid19_full_database
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10                    
#SBATCH --mem=200gb
#SBATCH --time=48:00:00
#SBATCH --output=test.%j.out
#SBATCH --error=test.%j.err


if [$# -eq 0]; then
  nextstrain build . --cores all --configfile only_custom_config.yaml
else
  ### Select region-specific data from the Covid-19 database that already be cleaned with the script "clean_database.sh" as background data
  while getopts 'l:u:s:q:h' OPTION; do
    case "$OPTION" in
      l)
        mindate="$OPTARG"
        echo "argument of min date: $mindate"
        #echo "--min-date $OPTARG"
        ;;
      u)
        maxdate="$OPTARG"
        echo "argument of max date: $maxdate"
        #echo "--max-date $OPTARG"
        ;;
      s)
        subsample_num="$OPTARG"
        echo "argument of subsample number: $subsample_num"
        #echo "--subsample-max-sequences $OPTARG"
        ;;
      q)
        aquery="$OPTARG"
        echo "argument of the query: $aquery"
        echo "--query \"$OPTARG\""
        ;;
      h)
        echo "script usage: $(basename $0) [-l min-date in format YYYY-MM-DD] [-u max-date in format YYYY-MM-DD] [-s the number of subsamples as background data ] [-o output the name of strains] [-h help] [-q specific-region]"
        ;;
      ?)
        echo "script usage: $(basename $0) [-l min-date in format YYYY-MM-DD] [-u max-date in format YYYY-MM-DD] [-s the number of subsamples ] [-o output the name of strains] [-h help] [-q specific-region]" >&2
        exit 1
        ;;
    esac
  done
  shift "$(($OPTIND -1))"
  augur filter \
    --metadata data/metadata_gisaid.tsv.gz \
    --query "$aquery" \
    --min-date $mindate \
    --max-date $maxdate \
    --exclude-ambiguous-dates-by any \
    --subsample-max-sequences $subsample_num \
    --output-strains background_strain.txt

  augur filter \
    --metadata data/metadata_gisaid.tsv.gz \
    --sequence-index data/sequence_index_gisaid.tsv.gz \
    --sequences data/sequences_gisaid.fasta.gz \
    --exclude-all \
    --include background_strain.txt \
    --output-metadata data/background_metadata_gisaid.tsv.gz \
    --output-sequences data/background_sequences_gisaid.fasta.gz

  nextstrain build . --cores all --configfile custom_and_background_config.yaml
fi
