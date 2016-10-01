#!/bin/sh

set -e

. "$GLUONDIR"/scripts/modules.sh

(
	echo 'src-link gluon ../../package'
	for feed in $GLUON_SITE_FEEDS $GLUON_FEEDS; do
		echo "src-link packages_$feed ../../packages/$feed"
	done
) > "$GLUONDIR"/lede/feeds.conf

rm -rf "$GLUONDIR"/lede/feeds
rm -rf "$GLUONDIR"/lede/package/feeds

"$GLUONDIR"/lede/scripts/feeds update -a
"$GLUONDIR"/lede/scripts/feeds install -a
