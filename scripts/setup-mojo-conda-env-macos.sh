# Setup conda virtualenv (mac)

# create conda environment named `venv` in pwd
conda env create -y -p venv --file environment.yml

# activate conda environment
conda activate ./venv

# export env var for mojo to use the correct libpython
export MOJO_PYTHON_LIBRARY="$(pwd)/venv/lib/libpython3.11.dylib"
