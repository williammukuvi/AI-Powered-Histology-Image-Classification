#!/bin/bash

#SBATCH --job-name=patch_extraction
#SBATCH --output=logs/patch_extraction_%j.out
#SBATCH --error=logs/patch_extraction_%j.err
#SBATCH --time=2:00:00                # Adjust as needed
#SBATCH --mem=16G                     # Adjust memory as needed
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

# Load required modules
ml jupyter/6.5.4

# Get input type (BCC or SCC)
TYPE=$1
if [[ "$TYPE" != "BCC" && "$TYPE" != "SCC" ]]; then
  echo "Please specify either BCC or SCC as the first argument."
  exit 1
fi

# Set directories based on input type
RAW_DIR="/home/francokrepel/blue/vabfmc/data/working/d.uriartediaz/francokrepel/project-root/data/raw/AN_Batch_*_${TYPE}"
PATCH_DIR="/home/francokrepel/blue/vabfmc/data/working/d.uriartediaz/francokrepel/project-root/data/patches/$TYPE"

# Create output directory if it doesn't exist
mkdir -p "$PATCH_DIR"
mkdir -p logs

# Process each .mrxs file in the raw directory
for slide_path in ${RAW_DIR}/*.mrxs; do
  # Ensure that the path is expanded correctly
  if [[ ! -f "$slide_path" ]]; then
    echo "Slide file not found: $slide_path"
    continue
  fi

  slide_name=$(basename "$slide_path" .mrxs)
  echo "Processing file: $slide_path"

  # Submit a job for each slide
  sbatch <<EOT
#!/bin/bash
#SBATCH --job-name=${slide_name}_patch_extraction
#SBATCH --output=logs/${slide_name}_patch_extraction.out
#SBATCH --error=logs/${slide_name}_patch_extraction.err
#SBATCH --time=2:00:00                # Adjust
#SBATCH --mem=2G                      # Adjust
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

# Run patch extraction for this slide
python -c "
from src.data_processing.tile_extraction import extract_patches
extract_patches('${slide_path}', '${PATCH_DIR}')
"
EOT

done