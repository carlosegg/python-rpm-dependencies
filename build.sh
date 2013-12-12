#!/bin/bash -x
DIR=$(dirname $(readlink -f $0))

function pythonEnv27(){
   pythondir=/usr
   python_version=2.7
   pythonbin=$pythondir/bin/python2.7
   prefix_name=tdigital-python$python_version-   
}

function pythonEnv26(){
   pythondir=/usr
   python_version=2.6
   pythonbin=$pythondir/bin/python
   prefix_name=tdigital-python$python_version-   
}

function pythonEnv24(){
   pythondir=/usr
   python_version=2.4
   pythonbin=$pythondir/bin/python
   prefix_name=tdigital-python$python_version-   
}

function createRpm(){
   local url=$1
   local templateFile=$2
   local externalDependencies=$3
   if [[ "$templateFile" == "" ]]; then
      echo "[ERROR] It's neccesary a template"
      return 1
   fi
   if [[ "$url" == *.zip ]]; then
      version=$(basename $url|sed s:"\.zip":"":g|sed s:".*-":"":g)
   else
      version=$(basename $url|sed s:"\.tar\.gz":"":g|sed s:".*-":"":g)
   fi
   package=$(basename $url)
   package=${package%*-${version}.*}
   release=1
   rpmdir=$DIR/target/$package/rpms/
   specdir=$rpmdir/SPECS
   sourcedir=$rpmdir/SOURCES
   rm -Rf $rpmdir && mkdir -p $sourcedir $specdir
   set -x
   echo "" >$specdir/$package.spec
   if [ "$externalDependencies" != "" ]; then
      echo "Requires:   $externalDependencies" >>$specdir/$package.spec
   fi 
   echo "
%define  template_external_dependencies \"$externalDependencies\"
%define prefix_name $prefix_name
%define python_dir $pythondir
%define python_version $python_version
%define python_bin $pythonbin
%define template_name $package
%define template_version $version
%define template_release $release
%define template_url $url"  >>$specdir/$package.spec
   cat $DIR/$templateFile >> $specdir/$package.spec
   if [ -d "$DIR/$package/SOURCES" ]; then
      rm -Rf $sourcedir
      cp -R "$DIR/$package/SOURCES" $rpmdir
   fi
   cd $sourcedir
   curl -O $url
   cd $rpmdir
   cat $rpmdir/SPECS/$package.spec
   rpmbuild -v --clean -ba $rpmdir/SPECS/$package.spec --define '_topdir '$rpmdir
}

function python27(){
   pythonEnv27
   createRpm https://pypi.python.org/packages/source/p/pymongo/pymongo-2.6.3.tar.gz templates/python-dep.spec.template
   return
   createRpm https://pypi.python.org/packages/source/t/tlslite/tlslite-0.4.6.tar.gz  templates/python-dep.spec.template
   createRpm https://pypi.python.org/packages/source/o/oauthlib/oauthlib-0.6.0.tar.gz templates/python-dep.spec.template
   createRpm https://pypi.python.org/packages/source/r/requests/requests-2.0.1.tar.gz templates/python-dep.spec.template 
   createRpm file://$DIR/local_packages/requests-oauthlib-0.4.0.tar.gz templates/python-dep.spec.template "tdigital-python2.7-requests tdigital-python2.7-oauthlib"
   createRpm file://$DIR/local_packages/jira-python-0.13.tar.gz templates/python-dep.spec.template "tdigital-python2.7-requests-oauthlib tdigital-python2.7-tlslite tdigital-python2.7-ipython"
   createRpm file:///$DIR/local_packages/XML2Dict-0.2.2.tar.gz templates/python-dep.spec.template
   createRpm https://pypi.python.org/packages/source/p/pyjavaproperties/pyjavaproperties-0.6.tar.gz templates/python-dep.spec.template
}

function python26(){
   pythonEnv26
   createRpm http://argparse.googlecode.com/files/argparse-1.2.1.tar.gz templates/python-dep.spec.template
   createRpm file://$DIR/local_packages/XML2Dict-0.2.2.tar.gz templates/python-dep.spec.template
   createRpm https://pypi.python.org/packages/source/p/pyjavaproperties/pyjavaproperties-0.6.tar.gz templates/python-dep.spec.template
}

function python24(){
   pythonEnv24
   createRpm https://pypi.python.org/packages/source/r/requests/requests-2.0.1.tar.gz templates/python-dep.spec.template 
   exit 1
   createRpm http://argparse.googlecode.com/files/argparse-1.2.1.tar.gz templates/python-dep.spec.template
   createRpm file://$DIR/local_packages/XML2Dict-0.2.2.tar.gz templates/python-dep.spec.template
   createRpm https://pypi.python.org/packages/source/p/pyjavaproperties/pyjavaproperties-0.6.tar.gz templates/python-dep.spec.template
}

function default_PythonEnv(){
   pythondir=/usr
   python_version=2.7
   pythonbin=$pythondir/bin/python2.7
   prefix_name=tdigital-python$python_version-   
}

python27
exit $?
createRpm http://c.pypi.python.org/packages/source/j/jira-python/jira-python-0.13.tar.gz templates/python-dep.spec.template
exit 0

createRpm https://pypi.python.org/packages/source/i/ipython/ipython-1.1.0.tar.gz templates/python-dep.spec.template
exit 0
createRpm http://c.pypi.python.org/packages/source/j/jira-python/jira-python-0.13.tar.gz templates/python-dep.spec.template
exit 0
#createRpm https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/u/ujson/ujson-1.33.zip templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/s/simplejson/simplejson-3.3.1.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.1.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/i/ipython/ipython-0.13.2.tar.gz templates/python-dep.spec.template
#createRpm https://pypi.python.org/packages/source/l/lettuce/lettuce-0.2.17.tar.gz templates/python-dep.spec.template
