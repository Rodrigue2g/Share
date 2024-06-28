#! bin/bash
#
curl -O https://repo.anaconda.com/archive/Anaconda3-2023.03-Linux-x86_64.sh

bash Anaconda3-2023.03-Linux-x86_64.sh

conda init

source ~/.bashrc

vim .bashrc

export PATH="$HOME/anaconda3/bin:$PATH"

source ~/.bashrc

conda init

conda init bash

source ~/.bashrc



conda create -n juliaenv

conda activate juliaenv

conda install -c conda-forge julia

conda install -c conda-forge notebook

conda install -c conda-forge nb_conda_kernels

conda install -c conda-forge jupyterlab

conda install -c conda-forge ipykernel


jupyter notebook --no-browser --port=8889 --allow-root
ssh -L 8888:localhost:8889 root@185.216.27.47


import Pkg
Pkg.update()
Pkg.build("IJulia")
Pkg.build("MbedTLS")


sudo apt-get update
sudo apt-get install libmbedtls-dev


sudo apt-get update
sudo apt-get install cmake


curl -fsSL https://install.julialang.org | sh

conda deactivate 
source ~/.bashrc
conda activate <env>

julia


