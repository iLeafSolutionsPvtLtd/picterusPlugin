#import "PicterusCameraPlugin.h"
#import "PicterusCameraView.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

#include <set>
#include <utility>

static PicterusCameraPlugin* sharedInstance_ = nullptr;

@interface PicterusCameraPlugin() <AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
@private PicterusCameraView* preview_;
@private AVCaptureSession* session_;
@private AVCapturePhotoOutput* photoOutput_;
@private AVCaptureVideoDataOutput* videoDataOutput_;
@private FlutterMethodChannel* channel_;
@private NSString* capturePath_;
}

@end

@implementation PicterusCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    sharedInstance_ = [[PicterusCameraPlugin alloc] init];
    sharedInstance_->channel_ = [FlutterMethodChannel
                methodChannelWithName:@"camera.picterus.com"
                binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:sharedInstance_ channel:sharedInstance_->channel_];
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
    } else if ([@"maxZoomFactor" isEqualToString:call.method]) {
        [self maxZoomFactor:[call arguments] result:result];
    } else if ([@"initialize" isEqualToString:call.method]) {
        [self initialize:[call arguments] result:result];
    } else if ([@"switchDevice" isEqualToString:call.method]) {
        [self switchDevice:[call arguments] result:result];
    } else if ([@"changeZoomFactor" isEqualToString:call.method]) {
        [self changeZoomFactor:[call arguments] result:result];
    } else if ([@"capture" isEqualToString:call.method]) {
        [self capture:[call arguments] result:result];
    } else if ([@"sensorSize" isEqualToString:call.method]) {
        [self sensorSize:[call arguments] result:result];
    } else if ([@"startStreaming" isEqualToString:call.method]) {
        [self startStreaming:[call arguments] result:result];
    } else if ([@"stopStreaming" isEqualToString:call.method]) {
        [self stopStreaming:[call arguments] result:result];
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
    NSMutableArray<NSString*> *reply =
    [[NSMutableArray alloc] initWithCapacity:3];
    auto ms = [photoOutput_ supportedFlashModes];
    for (auto i = 0; i < ms.count; ++i) {
        if (ms[i].integerValue == AVCaptureFlashModeOff) {
            [reply addObject:@"off"];
        } else if (ms[i].integerValue == AVCaptureFlashModeOn) {
            [reply addObject:@"on"];
        } else if (ms[i].integerValue == AVCaptureFlashModeAuto) {
            [reply addObject:@"auto"];
        }
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

-(void) maxZoomFactor:(NSString*)arguments result:(FlutterResult)result {
    AVCaptureDevice* device = deviceFromString(arguments);
    double z = device.activeFormat.videoMaxZoomFactor;
    result([NSNumber numberWithDouble: z]);
}

-(void) initialize:(NSDictionary*)arguments result:(FlutterResult)result {
    session_ = [[AVCaptureSession alloc] init];
    session_.sessionPreset = AVCaptureSessionPresetHigh;
    NSString* dev = [arguments objectForKey:@"device"];
    auto d = deviceFromString(dev);
    auto i = [[AVCaptureDeviceInput alloc] initWithDevice:d error:nil];
    [session_ addInput:i];
    AVCapturePhotoOutput* photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([session_ canAddOutput:photoOutput]) {
        [session_ addOutput:photoOutput];
        photoOutput_ = photoOutput;
        photoOutput_.highResolutionCaptureEnabled = YES;
    }
    if (preview_ != nullptr) {
        preview_.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session_];
        preview_.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    [session_ startRunning];
}

-(void) switchDevice:(NSDictionary*)arguments result:(FlutterResult)result {
    [session_ beginConfiguration];
    auto inputs = [session_ inputs];
    auto di = (AVCaptureDeviceInput*)[session_.inputs objectAtIndex:0];
    auto dn = di.device.position == AVCaptureDevicePositionBack ? @"front" : @"back";
    auto d = deviceFromString(dn);
    auto i = [[AVCaptureDeviceInput alloc] initWithDevice:d error:nil];
    for (auto i = 0; i < [inputs count]; ++i) {
        [session_ removeInput:inputs[i]];
    }
    [session_ addInput:i];
    for (auto i = 1; i < [inputs count]; ++i) {
        [session_ addInput:inputs[i]];
    }
    [session_ commitConfiguration];
}

-(void) changeZoomFactor:(NSNumber*)arguments result:(FlutterResult)result {
    auto d = [((AVCaptureDeviceInput*)[session_.inputs objectAtIndex:0]) device];
    [d lockForConfiguration:nil];
    d.videoZoomFactor = [arguments doubleValue];
    [d unlockForConfiguration];
}

-(void) capture:(NSDictionary*)arguments result:(FlutterResult)result {
    AVCaptureConnection* photoOutputConnection = [photoOutput_ connectionWithMediaType:AVMediaTypeVideo];
    photoOutputConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    AVCapturePhotoSettings* photoSettings = [AVCapturePhotoSettings photoSettings];
    capturePath_ = (NSString*)[arguments objectForKey:@"path"];
    NSString* fn = (NSString*)[arguments objectForKey:@"flashlightMode"];
    if ([fn isEqualToString: @"auto"]) {
        photoSettings.flashMode = AVCaptureFlashModeAuto;
    } else if ([fn isEqualToString: @"on"]) {
        photoSettings.flashMode = AVCaptureFlashModeOn;
    } else {
        photoSettings.flashMode = AVCaptureFlashModeOff;
    }
    if (@available(iOS 11.0, *)) {
        if (photoOutput_.isCameraCalibrationDataDeliverySupported) {
        //    photoSettings.isCameraCalibrationDataDeliveryEnabled = true;
        }
    }
    photoSettings.highResolutionPhotoEnabled = YES;
    [photoOutput_ capturePhotoWithSettings:photoSettings delegate:self];
}

-(void) sensorSize:(NSDictionary*)arguments result:(FlutterResult)result {
    NSMutableArray<NSString*> *reply =
    [[NSMutableArray alloc] initWithCapacity:3];
    auto d = ((AVCaptureDeviceInput*)[session_.inputs objectAtIndex:0]).device;
    auto f = d.activeFormat.formatDescription;
    auto s = CMVideoFormatDescriptionGetDimensions(f);
}

-(void) startStreaming:(NSDictionary*)arguments result:(FlutterResult)result {
    videoDataOutput_ = [AVCaptureVideoDataOutput new];
    videoDataOutput_.videoSettings =
    @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    [videoDataOutput_ setAlwaysDiscardsLateVideoFrames:YES];
    [videoDataOutput_ setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session_ addOutput:videoDataOutput_];
    [session_ commitConfiguration];
}

-(void) stopStreaming:(NSDictionary*)arguments result:(FlutterResult)result {
    [session_ removeOutput:videoDataOutput_];
    videoDataOutput_ = nullptr;
    [session_ commitConfiguration];
}

-(void) captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    auto b = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (b == nullptr) {
        return;
    }
    CVPixelBufferLockBaseAddress(b, 0);
    int bufferWidth = (int)CVPixelBufferGetWidth(b);
    int bufferHeight = (int)CVPixelBufferGetHeight(b);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(b);
    uint8_t *baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(b);

    CVPixelBufferRef pixelBufferCopy = nullptr;
    CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, kCVPixelFormatType_32BGRA, NULL, &pixelBufferCopy);
    CVPixelBufferLockBaseAddress(pixelBufferCopy, 0);
    uint8_t *copyBaseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(pixelBufferCopy);
    memcpy(copyBaseAddress, baseAddress, bufferHeight * bytesPerRow);
    CVPixelBufferUnlockBaseAddress(b, 0);
    CVPixelBufferUnlockBaseAddress(pixelBufferCopy, 0);
    [channel_ invokeMethod:@"frameStreamed" arguments:@{
                                                        @"buffer": [NSNumber numberWithInteger: reinterpret_cast<long>(pixelBufferCopy)],
                                                        @"rotation": [NSNumber numberWithInt:90]
                                                        }];
}

-(void) captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error  API_AVAILABLE(ios(11.0)) {
    CIImage* ci = [[CIImage alloc] initWithData:[photo fileDataRepresentation]];
    ci = [ci imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    auto di = (AVCaptureDeviceInput*)[session_.inputs objectAtIndex:0];
    if (di.device.position == AVCaptureDevicePositionFront) {
        ci = [ci imageByApplyingTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
    }
    auto cg = [[[CIContext alloc] init] createCGImage:ci fromRect:ci.extent];
    auto i = [[UIImage alloc] initWithCGImage: cg];
    [UIImageJPEGRepresentation(i, 1.0) writeToFile:capturePath_ atomically:true];
    [channel_ invokeMethod:@"captureFinished" arguments:capturePath_];
}

-(void) captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error {
    /// TODO For ios 10.
}

-(CVPixelBufferRef) pixelBuffer: (NSInteger) id {
    return reinterpret_cast<CVPixelBufferRef>(id);
}

@end
