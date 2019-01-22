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
        NSMutableArray<NSString *> *reply =
            [[NSMutableArray alloc] initWithCapacity:2];
        auto devices = [AVCaptureDevice devices];
        for (auto i = 0; i < [devices count]; ++i) {
            if ([devices[i] position] == AVCaptureDevicePositionBack) {
                [reply addObject:@"back"];
            } else if ([devices[i] position] == AVCaptureDevicePositionFront) {
                [reply addObject:@"front"];
            }
        }
        result(reply);
    } else if ([@"sizes" isEqualToString:call.method]) {
        AVCaptureDevice* device = deviceFromString((NSString*)call.arguments);
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
    } else if ([@"initialize" isEqualToString:call.method]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
