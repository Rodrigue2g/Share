#! bin/bash
# Install julia with conda to run jupyter notebooks on a linux (ubuntu) server
# Disclaimer: This is a pain in the ass (MbedTLS is messing everything up)
#

# First, start by installing anaconda on your server
# Fetch the installer
$ curl -O https://repo.anaconda.com/archive/Anaconda3-2023.03-Linux-x86_64.sh
# Then run the installation script
$ bash Anaconda3-2023.03-Linux-x86_64.sh

# The next few steps might be itterative (it sometimes takes more steps&time to have the bash config properly configured)
# Init conda
$ conda init
# Reload shell
$ source ~/.bashrc

# If needed (conda command not found) edit yoouur bash config
$ vim .bashrc
$ export PATH="$HOME/anaconda3/bin:$PATH"
# Reload shell
$ source ~/.bashrc

# If needed 
$ conda init bash
# Reload shell
$ source ~/.bashrc


# Create a new environnement
$ conda create -n <env_name>
# Activate it
$ conda activate <env_name>

# This might not be mandatory but some comments mentioned the need of cmake for MbedTLS to run smoothly
$ sudo apt-get update
$ sudo apt-get install libmbedtls-dev
$ sudo apt-get install cmake

# !! Important step !!
# Do NOT install julia like that:
$ conda install -c conda-forge julia
# Instead install it from
$ curl -fsSL https://install.julialang.org | sh

# Then deactive the conda env, reload your shell and re-activate your conda env
$ conda deactivate 
$ source ~/.bashrc
$ conda activate <env_name>

# This step might not be mandatory, but if you want to make sure Julia was installed correctly
# you can run these few steps to make sure the "MbedTLS" package won't cause any trouble in the nex steps
$ julia
$ import Pkg
$ Pkg.add("MbedTLS")
$ Pkg.build("MbedTLS"; verbose=true)
$ using MbedTLS
$ md = MbedTLS.MD(MbedTLS.MD_SHA256)
$ exit()

# Then you can install all your required packages (here is a non-exhaustive list) 
$ conda install -c conda-forge notebook
$ conda install -c conda-forge nb_conda_kernels
$ conda install -c conda-forge jupyterlab
$ conda install -c conda-forge ipykernel

# And install IJulia package from Julia CLI
$ julia
$ using Pkg
$ Pkg.add("IJulia")
$ exit()


# In the same conda env, you can now run
$ jupyter notebook --no-browser --port=8889 --allow-root

# And on your local machine you can run the following in order to access the jupyter notebook GUI
$ ssh -L 8888:localhost:8889 <user>@<server_ip>

# If you have followed all the steps correctly you should now be able to access your jupyter notebooks runing on your server
# http://localhost:8888/tree?token=secret_token

# If you want to remove your conda env for a fresh start
$ conda deactivate
$ conda env remove -n <env_name>
# Make sure it was well removed
$ conda env list
# Then you can start again from <Create a new environnement> step #L30
