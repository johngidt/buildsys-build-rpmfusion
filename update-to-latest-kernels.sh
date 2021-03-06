#! /bin/bash
print_kernellist()
{
	echo ${1}
	echo ${1}smp
	echo ${1}PAE
	echo ${1}lpae
}

if [[ ! "${1}" ]] ; then
	echo "Please call with verrel of latest standard kernel version" >&2
	exit 1
fi

if [[ ! $(rpmdev-packager) ]] ; then
	echo "Please set RPM_PACKAGER for rpmdev-bumpspec" >&2
	exit 1
fi

# update spec file
rpmdev-bumpspec -D -c "- rebuild for kernel ${1}" *.spec
# update buildsys-build-rpmfusion-kerneldevpkgs-current
print_kernellist ${1} > buildsys-build-rpmfusion-kerneldevpkgs-current

git diff -u
read
fedpkg clog; git commit -F clog -a
rm clog
rfpkg push
branch=$(git rev-parse --abbrev-ref HEAD)
 [ $branch == "master" ] && branch=rawhide
rfpkg build --target ${branch}-free-multilibs
