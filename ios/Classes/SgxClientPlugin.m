#import "SgxClientPlugin.h"
#if __has_include(<sgx_client/sgx_client-Swift.h>)
#import <sgx_client/sgx_client-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sgx_client-Swift.h"
#endif

@implementation SgxClientPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSgxClientPlugin registerWithRegistrar:registrar];
}
@end
