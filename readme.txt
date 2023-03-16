What is it?
Wrapper_Nextstrain_SARSCov2 is a wrapper for Nextstrain SARSCov-2 workflow. Nextstrain SARSCov-2 workflow can be used for VISUALIZATION & INTERPRETATION of SARSCov-2 samples from the world. However, users have to tediously modify config files and running commands every time it is used. The wrapper program allows users to save this tedious step. All it takes is a command in the command line.


What does it do?
The wrapper have two main functions: 1) Select some samples in current GISAID SARSCov-2 database for analysis and visualizaiton. 
                                     2) Use your own data, plus some data from GISAID SARSCov-2 database, and then compare, analyze and visualize them.


How to do?
1. Register for a GISAID (https://gisaid.org/) account for data download.

2. Install Nextstrain components:
	In this pipeline we select native install of Nextstrain. The install details can be found in  https://docs.nextstrain.org/en/latest/install.html

3. Actvate the nextstrain conda environment:
	$conda activate nextstrain

4. Download Nextstrain SARS-CoV-2 workflow from GitHub:
	$git clone https://github.com/nextstrain/ncov.git

5. Download the wrapper from GitHub (https://github.com/BPHL-Molecular/wrapper_Nextstrain_SARSCov2.git)
	$git clone https://github.com/BPHL-Molecular/wrapper_Nextstrain_SARSCov2.git

6. Change directory to the downloaded directory and move all wrapper files to the directory /ncov
	$cd ncov  #if the downloaded directory is named ncov, you can use this command.
	$move <your path>/wrapper_Nextstrain_SARSCoV2/* <your path>/ncov/

7. Prepare GISAID data for the Augur of Nextstrain:
	7.1 Download all SARS-CoV-2 metadata and sequences from GISAID to the data/ directory. (Download details can be found in https://docs.nextstrain.org/projects/ncov/en/latest/guides/data-prep/gisaid-full.html)
	   Then change the two file names to "sequences_fasta_original.tar.xz" and "metadata_tsv_original.tar.xz"
		
	7.2 Clean original sequence data and metadata
		$sbatch clean_database.sh  
		  
		Note: Use this command if HPC SLURM is used. If the linux system does not use SLURM, just run the command "bash clean_database.sh". 
		
8. The step is optional. If you want to only select some data from the GISAID datasets for analysis, please ignore this step. If you want to use your custom data and some background data selected from the GISAID datasets, or only your custom data, you need to perform this step.
	In this step, you should generate two files for your custom data. One is sequence file in fasta format, the other is metadata file in tsv format. Then move them to "/data" directory and rename them as "mycustom_metadata.tsv" and "mycustom_sequences.fasta". For each column in metadata file, leave empty if you do not have information to fill. 
	Two example files ("example_mycustom_metadata.tsv" and "example_mycustom_sequences.fasta") can be found in "/ncov" directory.

9. Option A: Select region-specific data from the GISAID databsets generated in Setp6, and then build Nextstrain workflow
			$sbatch select_specific_data.sh [-l min-date in format YYYY-MM-DD] [-u max-date in format YYYY-MM-DD] [-s the number of subsamples ] [-h help] [-q specific-region]
		
		Note: -l and -u are the limit of date, such as "-l 2021-10-05 -u 2022-04-23"
		      -s is the number of subsamples, such as "-s 100" 
		      -h to show help information
		      -q is a flag of specific-region. The optional arguments are region, country, division, and location, such as "-q "(region == 'North America') & (division != 'Washington')" ", "-q "region != 'North America'" ", "-q "(country == 'USA') & (division == 'Washington')" ". 
		      Although the command without arguments is allowed, beware to use it. As the whole data in the database (over 10 million sequences) will be selected for analysis. 

   Option B: Input your custom data and the specific background data selected from the GISAID databsets, and then build Nextstrain workflow
			$sbatch custom_data.sh [-l min-date in format YYYY-MM-DD] [-u max-date in format YYYY-MM-DD] [-s the number of subsamples ] [-h help] [-q specific-region]
		
		Note1: -l and -u are the limit of date, such as "-l 2021-10-05 -u 2022-04-23"
		      -s is the number of subsamples, such as "-s 100" 
		      -h to show help information
		      -q is a flag of specific-region. The optional arguments are region, country, division, and location, such as "-q "(region == 'North America') & (division != 'Washington')" ", "-q "region != 'North America'" ", "-q "(country == 'USA') & (division == 'Washington')" ". 
		      If the command without arguments, only custom data is used for analysis and no background data is selected from GISAID database. 
		Note2: If use Option B, you should first generate your custom metadata in tsv format and sequences in fasta format by yourself, and then move them to "/data" directory and rename them as "mycustom_metadata.tsv" and "mycustom_sequences.fasta". For the detailed introduction, please refer to Step

10. Visualize the results:
		Option 1: Find *.json file in auspice/ directory, and then drag & drop it to auspice.us (https://auspice.us/?c=num_date&tl=region) to view the interactive phylogeny.
		Option 2: If graphical user interfaces are available for your server/cluster, you can run the following command to view the interactive phylogeny:
		          $nextstrain view auspice/*.json

Important Note: From Step1 to Step7, they are only needed for the first time to run the pipeline. For next time, you need only go through step8 and step10. 
