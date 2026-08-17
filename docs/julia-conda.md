# Julia with Conda for Jupyter

Install Julia alongside a Conda environment for running Jupyter notebooks on an Ubuntu server.

## Install Anaconda

Fetch the installer:

```sh
curl -O https://repo.anaconda.com/archive/Anaconda3-2023.03-Linux-x86_64.sh
```

Run it:

```sh
bash Anaconda3-2023.03-Linux-x86_64.sh
```

Initialize Conda and reload the shell:

```sh
conda init
source ~/.bashrc
```

If `conda` is not found, add Anaconda to the shell path:

```sh
export PATH="$HOME/anaconda3/bin:$PATH"
source ~/.bashrc
```

If needed, initialize Bash explicitly:

```sh
conda init bash
source ~/.bashrc
```

## Create the Environment

Replace `<env_name>` with the environment name.

```sh
conda create -n <env_name>
conda activate <env_name>
```

Install system packages that can help with MbedTLS-related build issues:

```sh
sudo apt-get update
sudo apt-get install libmbedtls-dev cmake
```

## Install Julia

Do not install Julia through Conda for this setup:

```sh
conda install -c conda-forge julia
```

Use the official Julia installer instead:

```sh
curl -fsSL https://install.julialang.org | sh
```

If you see `CondaError: Run 'conda init' before 'conda activate'`, make sure you are inside the Conda environment and run:

```sh
sudo chown $USER ~/.bash_profile
curl -fsSL https://install.julialang.org | sh
```

Then reload and reactivate the environment:

```sh
conda deactivate
source ~/.bashrc
conda activate <env_name>
```

## Check MbedTLS

Open Julia:

```sh
julia
```

Run:

```julia
import Pkg
Pkg.add("MbedTLS")
Pkg.build("MbedTLS"; verbose=true)
using MbedTLS
md = MbedTLS.MD(MbedTLS.MD_SHA256)
exit()
```

## Install Jupyter Packages

```sh
conda install -c conda-forge notebook
conda install -c conda-forge nb_conda_kernels
conda install -c conda-forge jupyterlab
conda install -c conda-forge ipykernel
```

Install IJulia from the Julia CLI:

```sh
julia
```

```julia
using Pkg
Pkg.add("IJulia")
exit()
```

## Run Jupyter on the Server

```sh
jupyter notebook --no-browser --port=8889 --allow-root
```

Forward the remote port from your local machine:

```sh
ssh -L 8888:localhost:8889 <user>@<server_ip>
```

Open the notebook URL locally:

```txt
http://localhost:8888/tree?token=secret_token
```

## Remove the Environment

```sh
conda deactivate
conda env remove -n <env_name>
conda env list
```
