#import "PicterusCameraView.h"
#import "PicterusCameraPlugin.h"

@interface PicterusCameraView()
{
@private AVCaptureVideoPreviewLayer* previewLayer_;
}

@end

@implementation PicterusCameraView

-(id) initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args
{
    return [super initWithFrame:frame];
}

-(UIView*) view {
    return self;
}

-(AVCaptureVideoPreviewLayer*) previewLayer {
    return previewLayer_;
}

-(void) setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    previewLayer_ = previewLayer;
    [self.layer addSublayer:previewLayer_];
}

-(void) layoutSubviews {
    previewLayer_.frame = self.bounds;
}

@end

@implementation PicterusCameraViewFactory

-(NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                  viewIdentifier:(int64_t)viewId
                                       arguments:(id)args {
    auto r = [[PicterusCameraView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args];
    [[PicterusCameraPlugin sharedInstance] registerPreviewView:r];
    return r;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

@end

