#!/bin/sh
REPO="https://github.com/golang/go"
TAGFILTER="refs/tags/go"
DURL="https://dl.google.com/go"
APP="go"
APPBIN=$(which ${APP})
APPVER="${APPBIN} version | awk '{print \$3}'"

echo ${IDIR} ${BDIR}

# GLS="git ls-remote --tags ${REPO}"
# TGS="grep ${TAGFILTER}"
# TFIELD="awk '{print \$2}'"
# RCFILT="grep -v -e \"{}\$\" -e alpha -e beta -e \"[Rr][Cc].*\$\""
# TGTRIM="sed 's/refs\/tags\///'"

# V="${GLS} | ${TGS} | ${TFIELD} | ${RCFILT} | ${TGTRIM}"
# major=$(eval "${V} | awk -F'.' '{print \$1}' | ${TGS1}")
# minor=$(eval "${V} | grep ${major} | awk -F'.' '{print \$2}' | ${TGS2}")
# patch=$(eval "${V} | grep ${major}.${minor} | awk -F'.' '{print \$3}' | ${TGS2}")

# vers=""
# [ -z "${patch}" ] && vers=$major.$minor || vers=$major.$minor.$patch
# echo $vers

# download() {
#     echo "download $1 version"
#     echo "Installing $vers"
#     FN=${vers}.linux-amd64.tar.gz
#     echo sudo rm -f /tmp/${FN}
#     echo sudo rm -rf /tmp/${APP}_${vers}
#     echo wget -qc ${DURL}/${FN} -O /tmp/${FN}
#     echo sudo rm -rf ${IDIR}/${APP}
#     echo sudo tar axf /tmp/${FN} -C ${IDIR}
#     echo sudo ls ${IDIR}/go/bin | sudo xargs -I {} ln -sf ${IDIR}/go/bin/{} ${BDIR}/{}
#     echo sudo rm -f /tmp/${FN}
# }

# if [ -z "${APPBIN}" ]; then
#     echo "Not Installed"
#     download new
# else
#     echo "Installed"
#     APPMAJOR=$(eval $APPVER | awk -F'.' '{print $1}')
#     APPMINOR=$(eval $APPVER | awk -F'.' '{print $2}')
#     APPPATCH=$(eval $APPVER | awk -F'.' '{print $3}')
#     if [ $((${APPMAJOR})) -lt $((${major})) ]; then
#         download major
#     else
#         if [ $((${APPMINOR})) -lt $((${minor})) ]; then
#             download minor
#         else
#             if [ $((${APPPATCH})) -lt $((${patch})) ]; then
#                 download patch
#             else
#                 UpToDate
#             fi
#         fi
#     fi
# fi
