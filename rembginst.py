import glob
import subprocess
import os
import sys

# Get the directory path from command-line argument
whl_directory = sys.argv[1]  # sys.argv[1] is the first argument

# List all .whl files in the directory
whl_files = glob.glob(os.path.join(whl_directory, "*.whl"))

# Install each .whl file
for whl_file in whl_files:
    subprocess.run(["pip", "install", whl_file])