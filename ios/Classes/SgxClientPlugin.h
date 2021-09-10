#import <Flutter/Flutter.h>

@interface SgxClientPlugin : NSObject<FlutterPlugin>
@end

char *verify_mra_cert(const char *pem);