#!/usr/bin/bash
#SBATCH --account=bphl-umbrella
#SBATCH --qos=bphl-umbrella
#SBATCH --job-name=nextstrain_covid19_full_database
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10                    
#SBATCH --mem=200gb
#SBATCH --time=48:00:00
#SBATCH --output=select_specific_data.%j.out
#SBATCH --error=select_specific_data.%j.err


if [$# -eq 0]; then
  nextstrain build . --cores all --configfile alldata_config.yaml
else
  ### Select region-specific data from the Covid-19 database that already be cleaned with the script "clean_database.sh"
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
      #o)
        #output_strains="$OPTARG"
        #echo "argument: $output_strains"
        #echo "--output-strains $OPTARG"
        #;;
      q)
        aquery="$OPTARG"
        echo "argument of the query: $aquery"
        #echo "--query \"$OPTARG\""
        ;;
      h)
        echo "script usage: $(basename $0) [-l min-date in format YYYY-MM-DD] [-u max-date in format YYYY-MM-DD] [-s the number of subsamples ] [-o output the name of strains] [-h help] [-q specific-region]"
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
      --output-strains selected_strain.txt

  augur filter \
    --metadata data/metadata_gisaid.tsv.gz \
    --sequence-index data/sequence_index_gisaid.tsv.gz \
    --sequences data/sequences_gisaid.fasta.gz \
    --exclude-all \
    --include selected_strain.txt \
    --output-metadata data/subsampled_metadata_gisaid.tsv.gz \
    --output-sequences data/subsampled_sequences_gisaid.fasta.gz
    
    
  nextstrain build . --cores all --configfile select_config.yaml
fi
