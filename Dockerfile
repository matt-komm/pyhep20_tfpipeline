FROM jupyter/minimal-notebook:5197709e9f23

LABEL maintainer="Matthias Komm"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg dvipng && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Install Python 3 packages
RUN conda install --quiet --yes \
    'conda-forge::nb_conda' \
    'conda-forge::rise' \
    && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN conda create -n py27 \
    cmake \
    python=2.7.15 \
    conda-forge::tensorflow=1.6.0 \
    conda-forge::root=6.18.04 \
    conda-forge::Keras=2.1.6 \
    conda-forge::uproot=3.11.3 \
    conda-forge::h5py=2.10.0 \
    conda-forge::matplotlib \
    && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID

RUN git clone --depth 1 https://github.com/matt-komm/pyhep20_tfpipeline.git rtf

WORKDIR $HOME/rtf
