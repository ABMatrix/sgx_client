#import <Flutter/Flutter.h>

@interface SgxClientPlugin : NSObject<FlutterPlugin>
@end

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#define SGX_REPORT_BODY_RESERVED1_BYTES 12

#define SGX_REPORT_BODY_RESERVED2_BYTES 32

#define SGX_REPORT_BODY_RESERVED3_BYTES 32

#define SGX_REPORT_BODY_RESERVED4_BYTES 42

#define SGX_ISVEXT_PROD_ID_SIZE 16

#define SGX_CONFIGID_SIZE 64

#define SGX_ISV_FAMILY_ID_SIZE 16

#define SGX_REPORT_DATA_SIZE 64

#define SGX_CPUSVN_SIZE 16

#define SGX_HASH_SIZE 32

const char *verify_mra_cert(const char *pem);

void rust_cstr_free(char *s);