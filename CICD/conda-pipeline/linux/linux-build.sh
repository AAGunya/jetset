#path on miniconda docker
cd /workdir


#building
cd integration
git clone https://github.com/andreatramacere/jetset.git
cd jetset
git checkout develop
git reset --hard HEAD
git pull origin develop

#to build bessel fucntion locally


export USE_PIP='FALSE'
export JETSETBESSELBUILD='TRUE'

conda install --yes   -c astropy --file requirements.txt
rm jetkernel/mathkernel/F_Sync.dat
python setup.py clean
python setup.py install
python setup.py clean

#cd ..
#python -c 'import jetkernel; import os;p=os.path.join(jetkernel.__path__[0],"mathkernel"); os.system("cp jetset/jetkernel/mathkernel/F_Sync.dat %s"%p)'

export JETSETBESSELBUILD='FALSE'
cd CICD/conda-pipeline/linux

conda update --yes conda-build anaconda-client
conda create --yes --name jetset-cidc python=3.7 ipython anaconda-client conda-build ipython
conda activate jetset-cidc

export PKG_VERSION=$(cd ../../ && python -c "import jetset;print(jetset.__version__)")
rm -rf ../../../jetset/__pycache__/
echo  $PKG_VERSION


conda build purge
conda build .  -c defaults -c astropy  #for linux
export CONDABUILDJETSET=$(conda-build . --output)
echo  $CONDABUILDJETSET



#testing
conda install --yes   -c astropy --file ../../../requirements.txt
conda install  --yes --offline $CONDABUILDJETSET
cd /workdir/test
python -c 'import os;os.environ["MPLBACKEND"]="Agg"; from jetset.tests import test_functions; test_functions.test_short()'
conda deactivate