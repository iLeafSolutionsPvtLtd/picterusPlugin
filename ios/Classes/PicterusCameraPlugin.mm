#import "PicterusCameraPlugin.h"

@implementation PicterusCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"camera.picterus.com"
              binaryMessenger:[registrar messenger]];
    PicterusCameraPlugin* instance = [[PicterusCameraPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"cameras" isEqualToString:call.method]) {
        NSMutableArray<NSString *> *reply =
            [[NSMutableArray alloc] initWithCapacity:2];
        [reply addObject:@"front"];
        [reply addObject:@"back"];
        result(reply);
    } else if ([@"sizes" isEqualToString:call.method]) {
        NSMutableArray<NSDictionary<NSString*, NSNumber*>*> *reply =
            [[NSMutableArray alloc] initWithCapacity:2];
        [reply addObject:@{ @"width" : @720.0, @"height" : @480.0 }];
        [reply addObject:@{ @"width" : @1280.0, @"height" : @720.0 }];
        result(reply);
    } else if ([@"initialize" isEqualToString:call.method]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
