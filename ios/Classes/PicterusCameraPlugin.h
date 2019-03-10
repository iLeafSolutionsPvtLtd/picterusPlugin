#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@class PicterusCameraView;

@interface PicterusCameraPlugin : NSObject<FlutterPlugin>

+(PicterusCameraPlugin*) sharedInstance;

-(void) registerPreviewView:(PicterusCameraView*)view;

-(nullable CVPixelBufferRef) pixelBuffer:(NSInteger)id;

@end
