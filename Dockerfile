FROM jupyter/datascience-notebook 
USER root
RUN apt update && sudo apt upgrade -y && apt install -y zsh nano emacs ssh less && sudo apt autoremove -y
USER jovyan
RUN  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN chsh -s '/bin/zsh' jovyan
user root
cmd ["/bin/bash"]
