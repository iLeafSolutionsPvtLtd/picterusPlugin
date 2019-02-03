#import "PicterusCameraView.h"

#import <AVFoundation/AVFoundation.h>

@interface PicterusCameraView()
{
@private AVCaptureVideoPreviewLayer* videoPreview_;
@private AVCaptureSession* session_;
}

@end

@implementation PicterusCameraView

-(id) initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args
{
    self = [super initWithFrame:frame];
    session_ = [[AVCaptureSession alloc] init];
    session_.sessionPreset = AVCaptureSessionPreset1920x1080;
    auto d = [AVCaptureDevice devices][0];
    auto i = [[AVCaptureDeviceInput alloc] initWithDevice:d error:nil];
    auto o = [AVCaptureVideoDataOutput new];
    o.videoSettings =
    @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [o setAlwaysDiscardsLateVideoFrames:YES];
    [session_ addInput:i];
    [session_ addOutput:o];
    videoPreview_ = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session_];
    videoPreview_.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:videoPreview_];
    [session_ startRunning];
    return [super init];
}

-(UIView*) view {
    return self;
}

-(void) layoutSubviews {
    videoPreview_.frame = self.bounds;
}

@end

@implementation PicterusCameraViewFactory

-(NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                  viewIdentifier:(int64_t)viewId
                                       arguments:(id)args {
    return [[PicterusCameraView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args];
}

@end

