# Suite2p setup
Trying suite2p version: 0.12.0 and python version 3.8.12
1) `conda create python=3.8.12 --name suite2p --file conda_requirements.txt`
2) `conda activate suite2p`
    - `python --version`: 3.8.12
3) `pip install -r pip_requirements.txt`
    - `suite2p --version`: 0.12.0
4) `suite2p`
5) Try opening the stats.npy file from ./test_output2/plane0
6) It should just work.
    - `conda install ipykernel` for ipython kernel to run notebooks
    - `conda install ipywidgets` for widgets to play in notebooks

# Test examples:
- ../Data_Copy/2pData/test_data1: online example
- ../Data_Copy/2pData/test_data2: our example
- test_data3: our example not compressed maybe, but smaller somehow

# Suite2p usage
- `conda activate suite2p`
- make sure `python --version`  gives  3.8.12
- make sure `suite2p --version` gives v0.12.0
- `suite2p`

# Troubleshooting 231120:
- cells are sparse and super bright and seemingly nuclei-less
    - check other mice or FOVs
    - ask sofie, possibly dilute even more?, virus old/evaporated?, good vs bad batch?
- image is kinda grainy?
    - try another microscope
    - try different zoom and objective

