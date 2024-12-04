# In Apocrita on-demand start a session for "Code server BETA"

https://ondemand.hpc.qmul.ac.uk/pun/sys/dashboard/batch_connect/sys/code-server/session_contexts/new

# Click on the 3 lines in the top left corner then click "Terminal" then "New Terminal"

# In the terminal, copy paste these lines below on by one (ignore commented outline that start with #):

# Start a session on QMUL computing cluster with a maximum runtime of 8 hours and 20 GB of memory allocated.
# If it fails to start set time to 1 hour (1:00:00)

qlogin -l h_rt=8:00:00 -l h_vmem=20G 

# Load the Anaconda module, which is used for managing Python environments and packages.

module load anaconda3 

# Create a new Python environment named "mantisml2_env" with Python version 3.8.
conda create -n mantisml2_env python=3.8 

# Add "conda-forge," a popular community-driven repository, to the list of sources for installing Python packages.
conda config --append channels conda-forge 

# Activate the newly created Python environment. This environment isolates the packages used in this project from others on your system.
conda activate mantisml2_env 

# Download the Mantis-ML software (version 2.0) from a public GitHub repository to your current directory.
git clone https://github.com/astrazeneca-cgr-publications/mantis-ml-release-2.0.git 

# Move into the directory containing the downloaded Mantis-ML files. (using 'cd' command to change directory)
cd ./mantis-ml-release-2.0 

# Install a specific version of the "setuptools" package, which is needed for managing Python package installations. 
pip install setuptools==65.6.2 

# Install the Mantis-ML software in "editable" mode, allowing you to make changes to the code that are immediately applied without reinstallation.
pip install -e . 
