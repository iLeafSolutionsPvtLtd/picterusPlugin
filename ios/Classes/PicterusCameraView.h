#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PicterusCameraView : UIView<FlutterPlatformView>
{
}

-(nonnull id) initWithFrame:(CGRect)frame
     viewIdentifier:(int64_t)viewId
          arguments:(id _Nullable)args;

-(nonnull UIView*) view;

@property (nonnull) AVCaptureVideoPreviewLayer* previewLayer;

@end

@interface PicterusCameraViewFactory : NSObject<FlutterPlatformViewFactory>
{
}

-(nonnull NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                  viewIdentifier:(int64_t)viewId
                                       arguments:(id _Nullable)args;
@end
