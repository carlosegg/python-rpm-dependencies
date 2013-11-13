#!/bin/bash -x
DIR=$(dirname $(readlink -f $0))
pythondir=/usr
python_version=2.6
pythonbin=$pythondir/bin/python
prefix_name=tdigital-python$python_version-
function createRpm(){
   local url=$1
   local templateFile=$2
   if [[ "$templateFile" == "" ]; then
      echo "[ERROR] It's neccesary a template"
       return 1
   fi
   package=$(basename $url|sed s:"-.*":"":g)
   if [[ "$url" == *.zip ]]; then
      version=$(basename $url|sed s:"\.zip":"":g|sed s:".*-":"":g)
   else
      version=$(basename $url|sed s:"\.tar\.gz":"":g|sed s:".*-":"":g)
   fi
   release=1
   rpmdir=$DIR/target/$package/rpms/
   specdir=$rpmdir/SPECS
   sourcedir=$rpmdir/SOURCES
   rm -Rf $rpmdir && mkdir -p $sourcedir $specdir
   echo "
%define prefix_name $prefix_name
%define python_dir $pythondir
%define python_version $python_version
%define python_bin $pythonbin
%define template_name $package
%define template_version $version
%define template_release $release
%define template_url $url"  >$specdir/$package.spec
   cat $DIR/$templateFile >> $specdir/$package.spec
   if [ -d "$DIR/$package/SOURCES" ]; then
      rm -Rf $sourcedir
      cp -R "$DIR/$package/SOURCES" $rpmdir
   fi
   cd $sourcedir
   curl -O $url
   cd $rpmdir
   cat $rpmdir/SPECS/$package.spec
   read c
   rpmbuild -v --clean -ba $rpmdir/SPECS/$package.spec --define '_topdir '$rpmdir
}

createRpm https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz templates/python-dep.spec.template
createRpm https://pypi.python.org/packages/source/r/requests/requests-2.0.1.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/u/ujson/ujson-1.33.zip templates/python-dep.spec.template
createRpm https://pypi.python.org/packages/source/s/simplejson/simplejson-3.3.1.tar.gz templates/python-dep.spec.template
createRpm https://pypi.python.org/packages/source/p/pyjavaproperties/pyjavaproperties-0.6.tar.gz templates/python-dep.spec.template
#createRpm file:///home/vagrant/workspace/temp/XML2Dict-0.2.2.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.1.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/i/ipython/ipython-0.13.2.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/l/lettuce/lettuce-0.2.17.tar.gz templates/python-dep.spec.template
