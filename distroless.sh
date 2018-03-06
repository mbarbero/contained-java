#! /usr/bin/env bash

#set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

DEB_ARCHIVES="http://snapshot.debian.org/archive/debian/20180130T043019Z/pool/main"

cacerts() {
	echo "Installing ca-certificates"
	local cacerts="${1}"
	local deb=$(mktemp)
 	curl -s -o "${deb}" ${DEB_ARCHIVES}/c/ca-certificates/ca-certificates_20170717_all.deb 
	ar -x "${deb}" data.tar.xz
	tar -xf data.tar.xz ./usr/share/ca-certificates

	mkdir -p $(dirname "${cacerts}")

	local certs=$(find usr/share/ca-certificates -type f | sort)
	for cert in $certs; do
		cat $cert >> ${cacerts}
	done

	rm data.tar.xz
	rm -rf usr/share/ca-certificates
	rm "${deb}"
}

cacerts_java() {
	echo "Installing Java ca-certificates"
	local cacerts="${1}"
	
	mkdir -p $(dirname $(readlink -f "${cacerts}"))

	local cid=$(docker run -d debian:stretch-slim sh -c "apt-get update && apt-get install -y -q ca-certificates-java")
	docker attach ${cid} > /dev/null 2>&1
	docker cp ${cid}:/etc/ssl/certs/java/cacerts ${cacerts}
	docker rm ${cid} > /dev/null 2>&1
}

genid() {
	hexdump -n 32 -e '8/4 "%08x"' /dev/random
}

install_deb() {
	echo "Installing deb package $(basename ${2})"
	local out="${1}"
	local path="${2}"
	local deb=$(mktemp)
	local data=$(mktemp -d)
	curl -s -o "${deb}" "${DEB_ARCHIVES}/${path}"
	
	ar -x "${deb}" data.tar.xz
	tar -C "${data}" -xf data.tar.xz  

	cp -r ${data}/* "${out}"

	rm data.tar.xz
	rm -rf "${data}"
	rm "${deb}"
}

cleanup_layer() {
	local layer="${1}"

	rm -rf ${layer}/usr/share/doc
	rm -rf ${layer}/usr/share/man
}

_create_base_layer() {
	local layer="${1}"

	mkdir -p ${layer}/etc
	echo "root:x:0:0:user:/home:/bin/bash" > "${layer}/etc/passwd"
	echo "root:x:0:" > "${layer}/etc/group"

	cat <<EOT >> "${layer}/etc/os-release"
PRETTY_NAME="Distroless"
NAME="Debian GNU/Linux"
ID="debian"
VERSION_ID="9"
VERSION="Debian GNU/Linux 9 (stretch)"
HOME_URL="https://github.com/GoogleCloudPlatform/distroless"
SUPPORT_URL="https://github.com/GoogleCloudPlatform/distroless/blob/master/README.md"
BUG_REPORT_URL="https://github.com/GoogleCloudPlatform/distroless/issues/new"
EOT

	mkdir -p "${layer}/tmp"
	chmod 01777 "${layer}/tmp"

	cacerts "${layer}/etc/ssl/certs/ca-certificates.crt"

	install_deb "${layer}" g/glibc/libc6_2.24-11+deb9u1_amd64.deb
	install_deb "${layer}" o/openssl1.0/libssl1.0.2_1.0.2l-2+deb9u1_amd64.deb
	install_deb "${layer}" o/openssl/openssl_1.1.0f-3+deb9u1_amd64.deb
	install_deb "${layer}" n/netbase/netbase_5.4_all.deb
	install_deb "${layer}" t/tzdata/tzdata_2017c-0+deb9u1_all.deb
}

create_java_layer() {
	local base_layer="${1}"
	local layer="${2}"

	cp -r "${base_layer}" "${layer}" 
	cacerts_java "${layer}" ${layer}/etc/ssl/certs/java/cacerts
	install_deb "${layer}" z/zlib/zlib1g_1.2.8.dfsg-5_amd64.deb
}

create_openj9_layer() {
	local base_layer="${1}"
	local layer="${2}"

	cp -r "${base_layer}" "${layer}" 
	install_deb "${layer}" g/gcc-6/libgcc1_6.3.0-18_amd64.deb
}

create_openjdk_official_layer() {
	local base_layer="${1}"
	local layer="${2}"

	cp -r "${base_layer}" "${layer}" 
	install_deb "${layer}" g/gcc-6/libgcc1_6.3.0-18_amd64.deb
	install_deb "${layer}" g/gcc-6/libstdc++6_6.3.0-18_amd64.deb
}

create_layer_withmetadata() {
	local layer="${1}"
	local build_dir="${2}"
	local repoid="${3}"

	layerid=$(genid)
	mkdir -p ${build_dir}/${layerid}
	tar -C ${layer} -cf ${build_dir}/${layerid}/layer.tar .	

	echo -n "{\"${repoid}\":{\"latest\":\"${layerid}\"}}" > ${build_dir}/repositories

	configid=$(genid)
	echo -n "[{\"Config\":\"${configid}.json\",\"RepoTags\":[\"${repoid}:latest\"],\"Layers\":[\"${layerid}/layer.tar\"]}]" > ${build_dir}/manifest.json

	echo -n "{\"architecture\": \"amd64\", \"author\": \"mbarbero\", \"config\": {\"Env\": [\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"]}, \"created\": \"1970-01-01T00:00:00Z\", \"history\": [{\"author\": \"mbarbero\", \"created\": \"1970-01-01T00:00:00Z\", \"created_by\": \"hand made...\"}], \"os\": \"linux\", \"rootfs\": {\"diff_ids\": [\"sha256:$(sha256sum ${build_dir}/${layerid}/layer.tar | awk '{print $1}')\"], \"type\": \"layers\"}}" > ${build_dir}/${configid}.json

	echo -n "1.0" > ${build_dir}/${layerid}/VERSION

	echo -n "{\"id\":\"${layerid}\",\"created\":\"1970-01-01T00:00:00Z\",\"container_config\":{\"Hostname\":\"\",\"Domainname\":\"\",\"User\":\"\",\"AttachStdin\":false,\"AttachStdout\":false,\"AttachStderr\":false,\"Tty\":false,\"OpenStdin\":false,\"StdinOnce\":false,\"Env\":null,\"Cmd\":null,\"Image\":\"\",\"Volumes\":null,\"WorkingDir\":\"\",\"Entrypoint\":null,\"OnBuild\":null,\"Labels\":null},\"author\":\"Bazel\",\"config\":{\"Hostname\":\"\",\"Domainname\":\"\",\"User\":\"\",\"AttachStdin\":false,\"AttachStdout\":false,\"AttachStderr\":false,\"Tty\":false,\"OpenStdin\":false,\"StdinOnce\":false,\"Env\":[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"],\"Cmd\":null,\"Image\":\"\",\"Volumes\":null,\"WorkingDir\":\"\",\"Entrypoint\":null,\"OnBuild\":null,\"Labels\":null},\"architecture\":\"amd64\",\"os\":\"linux\"}" > ${build_dir}/${layerid}/json

	tar -C "${build_dir}" -cO . | docker load 
}

out="target/distroless"
rm -rf ${out}

mkdir -p "${out}/layer_base"
_create_base_layer "${out}/layer_base"
create_layer_withmetadata "${out}/layer_base" "${out}/base" "mbarbero/distroless-base"

create_java_layer "${out}/layer_base" "${out}/layer_java"
create_layer_withmetadata "${out}/layer_java" "${out}/java" "mbarbero/distroless-java"

create_openj9_layer "${out}/layer_java" "${out}/layer_openj9" 
create_layer_withmetadata "${out}/layer_openj9" "${out}/openj9" "mbarbero/distroless-openj9"

create_openjdk_official_layer "${out}/layer_java" "${out}/layer_openjdk_official" 
create_layer_withmetadata "${out}/layer_openjdk_official" "${out}/openjdk_official" "mbarbero/distroless-openjdk-official"
