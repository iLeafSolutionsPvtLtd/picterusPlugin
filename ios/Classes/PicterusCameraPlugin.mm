#import "PicterusCameraPlugin.h"

#import <AVFoundation/AVFoundation.h>

#include <set>
#include <utility>

@implementation PicterusCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"camera.picterus.com"
              binaryMessenger:[registrar messenger]];
    PicterusCameraPlugin* instance = [[PicterusCameraPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

namespace {
    AVCaptureDevice* deviceFromString(NSString* s) {
        auto p = AVCaptureDevicePositionBack;
        if ([s isEqualToString:@"front"]) {
            p = AVCaptureDevicePositionFront;
        }
        auto devices = [AVCaptureDevice devices];
        for (auto i = 0; i < [devices count]; ++i) {
            if (devices[i].position == p) {
                return devices[i];
            }
        }
        return nullptr;
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"devices" isEqualToString:call.method]) {
        [self devices:result];
    } else if ([@"sizes" isEqualToString:call.method]) {
        [self sizes:[call arguments] result:result];
    } else if ([@"flashlightModes" isEqualToString:call.method]) {
        [self flashlightModes:[call arguments] result:result];
    } else if ([@"initialize" isEqualToString:call.method]) {
        [self initialize:[call arguments] result:result];
    } else if ([@"updateConfiguration" isEqualToString:call.method]) {
        [self updateConfiguration:[call arguments] result:result];
    } else if ([@"capture" isEqualToString:call.method]) {
        [self updateConfiguration:[call arguments] result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

-(void) devices:(FlutterResult)result {
    NSMutableArray<NSString *> *reply = [[NSMutableArray alloc] initWithCapacity:2];
    auto devices = [AVCaptureDevice devices];
    for (auto i = 0; i < [devices count]; ++i) {
        if ([devices[i] position] == AVCaptureDevicePositionBack) {
            [reply addObject:@"back"];
        } else if ([devices[i] position] == AVCaptureDevicePositionFront) {
            [reply addObject:@"front"];
        }
    }
    result(reply);
}

-(void) sizes:(NSString*)arguments result:(FlutterResult)result {
    AVCaptureDevice* device = deviceFromString(arguments);
    NSMutableArray<NSDictionary<NSString*, NSNumber*>*> *reply =
    [[NSMutableArray alloc] initWithCapacity:2];
    if (device == nullptr) {
        result(reply);
    }
    auto formats = [device formats];
    std::set<std::pair<double, double>> dimensions;
    for (auto i = 0; i < [formats count]; ++i) {
        auto d = CMVideoFormatDescriptionGetDimensions([formats[i] formatDescription]);
        dimensions.insert({
            static_cast<double>(d.width),
            static_cast<double>(d.height)
        });
    }
    for (auto d : dimensions) {
        [reply addObject:@{@"width" : [NSNumber numberWithDouble: d.first],
                           @"height" : [NSNumber numberWithDouble: d.second]}];
    }
    result(reply);
}

-(void) flashlightModes:(NSString*)arguments result:(FlutterResult)result {
    AVCaptureDevice* device = deviceFromString(arguments);
    NSMutableArray<NSString*> *reply =
    [[NSMutableArray alloc] initWithCapacity:2];
    if (device == nullptr) {
        result(reply);
    }
    if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
        [reply addObject:@"off"];
    }
    if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
        [reply addObject:@"on"];
    }
    if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [reply addObject:@"auto"];
    }
    result(reply);
}

-(void) initialize:(id _Nullable)arguments result:(FlutterResult)result {

}

-(void) updateConfiguration:(id _Nullable)arguments result:(FlutterResult)result {

}

-(void) capture:(id _Nullable)arguments result:(FlutterResult)result {

}

@end
