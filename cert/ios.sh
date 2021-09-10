#bin/sh

LIBFILE=target/universal/release/libverify_mra_cert.a

[ -f "$LIBFILE" ] && cp "$LIBFILE" ../ios
