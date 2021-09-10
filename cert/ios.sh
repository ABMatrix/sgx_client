#bin/sh

LIBFILE=target/universal/release/libverify_mra_cert.a

[ -f "$LIBFILE" ] && cp "$LIBFILE" ../ios

cbindgen -c cbindgen.toml --create cert --output target/cert.h
cat /target/bindings.h >> ../ios/Classes/SgxClientPlugin.h