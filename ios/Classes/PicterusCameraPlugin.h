#import <Flutter/Flutter.h>

@class PicterusCameraView;

@interface PicterusCameraPlugin : NSObject<FlutterPlugin>

+(PicterusCameraPlugin*) sharedInstance;

-(void) registerPreviewView:(PicterusCameraView*)view;

@end
