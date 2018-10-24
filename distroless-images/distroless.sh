#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

#DEB_ARCHIVES="http://snapshot.debian.org/archive/debian/20180416T154447Z/pool/main"
#http://snapshot.debian.org/archive/debian/20091004T111800Z/dists/sid/main/binary-amd64/Packages.gz
DEB_ARCHIVES="http://http.debian.net/debian/pool/main"

_arx() {
	local archive="${1}"; shift
	local files="$*"
	pushd "$(dirname "${archive}")" &> /dev/null
	ar -x "$(basename "${archive}")" ${files}
	popd &> /dev/null
}

_cacerts() {
	echo "Installing $(basename ${2})"
	local cacerts="${1}"
	local cacerts_deb="${2}"
	local datadir=$(mktemp -d)
 	curl -sL -o "${datadir}/ca-certificates.deb" ${DEB_ARCHIVES}/${cacerts_deb}

	_arx "${datadir}/ca-certificates.deb" "data.tar.xz"
	tar -C "${datadir}" -xf "${datadir}/data.tar.xz" ./usr/share/ca-certificates
	
	mkdir -p $(dirname "${cacerts}") && cat /dev/null >| "${cacerts}"

	local certs=$(find ${datadir}/usr/share/ca-certificates -type f | sort)
	for cert in $certs; do
		cat $cert >> "${cacerts}"
	done

	rm -rf "${datadir}"
}

_cacerts_java() {
	echo "Installing Java ca-certificates (${2})"
	local cacerts="${1}"
	local debdistrib="${2}"
	
	mkdir -p $(dirname "${cacerts}")

	local cid=$(docker run -d debian:${debdistrib} sh -c "apt-get update && apt-get install --no-install-recommends -y -q ca-certificates-java")
	docker attach ${cid} > /dev/null 2>&1
	docker cp ${cid}:/etc/ssl/certs/java/cacerts ${cacerts}
	docker rm ${cid} > /dev/null 2>&1
}

_genid() {
	hexdump -n 32 -e '8/4 "%08x"' /dev/urandom
}

_install_deb() {
	echo "Installing deb package $(basename ${2})"
	local out="${1}"
	local path="${2}"
	local deb=$(mktemp)
	local data=$(mktemp -d)
	curl -sL -o "${deb}" "${DEB_ARCHIVES}/${path}"
	
	_arx "${deb}" data.tar.xz
	tar -C "${data}" -xf $(dirname ${deb})/data.tar.xz  

	cp -r ${data}/* "${out}"

	rm -rf "${data}"
	rm $(dirname ${deb})/data.tar.xz "${deb}"
}

_cleanup_layer() {
	echo "Cleaning up layer ${1}"
	local layer="${1}"

	rm -rf ${layer}/usr/share/doc
	rm -rf ${layer}/usr/share/man
	rm -rf ${layer}/usr/share/base-files
	rm -rf ${layer}/usr/share/common-licenses
	rm -rf ${layer}/usr/share/lintian
	
	find "${1}" -depth -type d -empty -exec !-name tmp rmdir "{}" \;
}

_import_parent_image() {
	echo "Importing parent image ${1}"
	local parent_image_tar="${1}"
	local layer="${2}"

	local parent_layer_tar="$(tar -xOf ${parent_image_tar} ./manifest.json | jq -r '.[0] | .Layers[0]')"
	tar -xOf ${parent_image_tar} "./${parent_layer_tar}" | tar -C "${layer}" -xf -
}

_create_image() {
	echo "Creating image ${4}"
	local layer="${1}"
	local repo="${2}"
	local tag="${3}"
	local output="${4}"

	local image_dir="$(dirname ${output})/image"
	local layerid=$(_genid)
	mkdir -p ${image_dir}/${layerid}
	tar -C ${layer} -cf ${image_dir}/${layerid}/layer.tar .	

	echo -n "{\"${repo}\":{\"${tag}\":\"${layerid}\"}}" > ${image_dir}/repositories

	local configid=$(_genid)
	echo -n "[{\"Config\":\"${configid}.json\",\"RepoTags\":[\"${repo}:${tag}\"],\"Layers\":[\"${layerid}/layer.tar\"]}]" > ${image_dir}/manifest.json

	echo -n "{\"architecture\": \"amd64\", \"author\": \"mbarbero\", \"config\": {\"Env\": [\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt\"]}, \"created\": \"1970-01-01T00:00:00Z\", \"history\": [{\"author\": \"mbarbero\", \"created\": \"1970-01-01T00:00:00Z\", \"created_by\": \"hand made...\"}], \"os\": \"linux\", \"rootfs\": {\"diff_ids\": [\"sha256:$(sha256sum ${image_dir}/${layerid}/layer.tar | awk '{print $1}')\"], \"type\": \"layers\"}}" > ${image_dir}/${configid}.json

	echo -n "1.0" > ${image_dir}/${layerid}/VERSION

	echo -n "{\"id\":\"${layerid}\",\"created\":\"1970-01-01T00:00:00Z\",\"container_config\":{\"Hostname\":\"\",\"Domainname\":\"\",\"User\":\"\",\"AttachStdin\":false,\"AttachStdout\":false,\"AttachStderr\":false,\"Tty\":false,\"OpenStdin\":false,\"StdinOnce\":false,\"Env\":null,\"Cmd\":null,\"Image\":\"\",\"Volumes\":null,\"WorkingDir\":\"\",\"Entrypoint\":null,\"OnBuild\":null,\"Labels\":null},\"author\":\"Bazel\",\"config\":{\"Hostname\":\"\",\"Domainname\":\"\",\"User\":\"\",\"AttachStdin\":false,\"AttachStdout\":false,\"AttachStderr\":false,\"Tty\":false,\"OpenStdin\":false,\"StdinOnce\":false,\"Env\":[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt\"],\"Cmd\":null,\"Image\":\"\",\"Volumes\":null,\"WorkingDir\":\"\",\"Entrypoint\":null,\"OnBuild\":null,\"Labels\":null},\"architecture\":\"amd64\",\"os\":\"linux\"}" > ${image_dir}/${layerid}/json

	tar -C "${image_dir}" -cO -f "${output}" .
}

create_base() {
	local layer_dir="${1}"

	_install_deb "${layer_dir}" b/base-files/base-files_9.9+deb9u5_amd64.deb
	echo "root:x:0:0:user:/home:/bin/bash" > "${layer_dir}/etc/passwd"
	echo "root:x:0:" > "${layer_dir}/etc/group"
	chmod 0644 "${layer_dir}/etc/passwd" "${layer_dir}/etc/group"
	
	_cacerts "${layer_dir}/etc/ssl/certs/ca-certificates.crt" c/ca-certificates/ca-certificates_20161130+nmu1+deb9u1_all.deb
	_install_deb "${layer_dir}" g/glibc/libc6_2.24-11+deb9u3_amd64.deb
	_install_deb "${layer_dir}" o/openssl1.0/libssl1.0.2_1.0.2l-2+deb9u3_amd64.deb
	_install_deb "${layer_dir}" o/openssl/openssl_1.1.0f-3+deb9u2_amd64.deb
	_install_deb "${layer_dir}" n/netbase/netbase_5.4_all.deb
	_install_deb "${layer_dir}" t/tzdata/tzdata_2018e-0+deb9u1_all.deb
}

create_base_unstable() {
	local layer_dir="${1}"

	_install_deb "${layer_dir}" b/base-files/base-files_10.1_amd64.deb
	echo "root:x:0:0:user:/home:/bin/bash" > "${layer_dir}/etc/passwd"
	echo "root:x:0:" > "${layer_dir}/etc/group"
	chmod 0644 "${layer_dir}/etc/passwd" "${layer_dir}/etc/group"
	
	_cacerts "${layer_dir}/etc/ssl/certs/ca-certificates.crt" c/ca-certificates/ca-certificates_20180409_all.deb
	_install_deb "${layer_dir}" g/glibc/libc6_2.27-6_amd64.deb
	_install_deb "${layer_dir}" o/openssl1.0/libssl1.0.2_1.0.2o-1_amd64.deb
	_install_deb "${layer_dir}" o/openssl/openssl_1.1.1-1_amd64.deb
	_install_deb "${layer_dir}" n/netbase/netbase_5.4_all.deb
	_install_deb "${layer_dir}" t/tzdata/tzdata_2018f-1_all.deb
}

add_jbase() {
	local layer_dir="${1}"
	_cacerts_java "${layer_dir}/etc/ssl/certs/java/cacerts" "stretch"
	_install_deb "${layer_dir}" z/zlib/zlib1g_1.2.8.dfsg-5_amd64.deb
}

add_jbase_unstable() {
	local layer_dir="${1}"
	_cacerts_java "${layer_dir}/etc/ssl/certs/java/cacerts" "sid"
	_install_deb "${layer_dir}" z/zlib/zlib1g_1.2.11.dfsg-1_amd64.deb
}

add_libgcc1() {
	local layer_dir="${1}"
	_install_deb "${layer_dir}" g/gcc-6/libgcc1_6.3.0-18+deb9u1_amd64.deb
}

add_libgcc1_unstable() {
	local layer_dir="${1}"
	_install_deb "${layer_dir}" g/gcc-8/libgcc1_8.2.0-8_amd64.deb
}

add_libstdcpp6() {
	local layer_dir="${1}"
	_install_deb "${layer_dir}" g/gcc-6/libstdc++6_6.3.0-18+deb9u1_amd64.deb
}

add_libstdcpp6_unstable() {
	local layer_dir="${1}"
	_install_deb "${layer_dir}" g/gcc-8/libstdc++6_8.2.0-8_amd64.deb
}

f="${1}"
repo="${2}"
tag="${3}"
image_tar="${4}"
parent_image_tar="${5:-}"

layer_dir="$(dirname "${image_tar}")/layer"
rm -rf "${layer_dir}" && mkdir -p "${layer_dir}"

if [[ ! -z ${parent_image_tar} ]]; then
	_import_parent_image "${parent_image_tar}" "${layer_dir}"	
fi

$f "${layer_dir}"

_cleanup_layer "${layer_dir}"
_create_image "${layer_dir}" "${repo}" "${tag}" "${image_tar}"
