#import "PicterusCameraPlugin.h"
#import "PicterusCameraView.h"

#import <AVFoundation/AVFoundation.h>

#include <set>
#include <utility>

static PicterusCameraPlugin* sharedInstance_ = nullptr;

@interface PicterusCameraPlugin() {
@private PicterusCameraView* preview_;
@private AVCaptureSession* session_;
}

@end

@implementation PicterusCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"camera.picterus.com"
              binaryMessenger:[registrar messenger]];
    sharedInstance_ = [[PicterusCameraPlugin alloc] init];
    [registrar addMethodCallDelegate:sharedInstance_ channel:channel];
    auto f = [[PicterusCameraViewFactory alloc] init];
    [registrar registerViewFactory:f withId:@"CameraView"];
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

+(PicterusCameraPlugin*) sharedInstance {
    return sharedInstance_;
}

-(void) registerPreviewView:(PicterusCameraView *)view {
    preview_ = view;
    if (session_ != nullptr && session_.isRunning) {
        preview_.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session_];
        preview_.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"devices" isEqualToString:call.method]) {
        [self devices:result];
    } else if ([@"sizes" isEqualToString:call.method]) {
        [self sizes:[call arguments] result:result];
    } else if ([@"flashlightModes" isEqualToString:call.method]) {
        [self flashlightModes:[call arguments] result:result];
    } else if ([@"focusModes" isEqualToString:call.method]) {
        [self focusModes:[call arguments] result:result];
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
    [[NSMutableArray alloc] initWithCapacity:3];
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

-(void) focusModes:(NSString*)arguments result:(FlutterResult)result {
    AVCaptureDevice* device = deviceFromString(arguments);
    NSMutableArray<NSString*> *reply =
    [[NSMutableArray alloc] initWithCapacity:3];
    if (device == nullptr) {
        result(reply);
    }
    [reply addObject:@"off"];
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [reply addObject:@"auto"];
    }
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [reply addObject:@"manual"];
    }
    result(reply);
}

-(void) initialize:(NSDictionary*)arguments result:(FlutterResult)result {
    session_ = [[AVCaptureSession alloc] init];
    session_.sessionPreset = AVCaptureSessionPresetHigh;
    NSString* dev = [arguments objectForKey:@"device"];
    auto d = deviceFromString(dev);
    auto i = [[AVCaptureDeviceInput alloc] initWithDevice:d error:nil];
    auto o = [AVCaptureVideoDataOutput new];
    o.videoSettings =
    @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [o setAlwaysDiscardsLateVideoFrames:YES];
    [session_ addInput:i];
    [session_ addOutput:o];
    if (preview_ != nullptr) {
        preview_.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session_];
        preview_.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    [session_ startRunning];
}

-(void) updateConfiguration:(id _Nullable)arguments result:(FlutterResult)result {

}

-(void) capture:(id _Nullable)arguments result:(FlutterResult)result {

}

@end
