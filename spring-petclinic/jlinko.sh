#! /usr/bin/env sh

jlink \
	--compress 2 \
	--no-header-files \
	--no-man-pages \
	--dedup-legal-notices=error-if-not-same-content \
	--strip-debug \
	--vm=server \
	--exclude-jmod-section=man \
	--exclude-jmod-section=headers \
  ${@}
