# djakToolbox
djakToolbox (dee-jack toolbox) is a master module that shall hold all new generalized tools I develop for various engineering, physics, simulation and/or surrogate (meta) model type projects. djakToolbox works as of now, but the submodules are still under heavy construction and I will actively be adding to them as I go. If you are interested in contributing and don't know how, you can follow the general instructions found [here](https://kbroman.org/github_tutorial/pages/fork.html)

recommended install method (linux)
==================================
if using the 'ssh' option when cloning, make sure you have followed the instructions [here](https://zzpanqing.github.io/2017/02/28/github-push-without-username-and-password.html)

1. navigate to directory you wish djakToobox to be placed in  
2. select either the ssh url XOR the https url:  
  * ssh url: &nbsp; &nbsp; &nbsp; &nbsp; git@github.com:jacluff1/djakToolbox.git  
  * https url: &nbsp; &nbsp; &nbsp; https://github.com/jacluff1/djakToolbox.git  
3. enter in the terminal:  
```bash
git clone <either url>
cd djakTools
source install.sh
```

if you want to install all available sub-modules, leave as is (no arguments given to install.sh); if you only want a barebones install (only required sub-modules):
```bash
source install.sh barebones
```
this will only install the barebones packages:
* BASH  
* fileme  
* printme  

if you want to install barebones + only the optional packages you want:
```bash
source install.sh <args>
```
the optional packages:
* constants  
* doepy  
* mathpy  
* mlpy  
* physicspy  
* plotme  

for example, if you only wanted to add doepy and plotme:
```bash
source install.sh doepy plotme
```

recommended update method (linux)
=================================
enter in the terminal (from djakTools home directory)
```bash
source update.sh
```
if you have decided to add more packages to your existing build:
```bash
source update.sh <args>
```
where args are the names of any packages you would like to build 
