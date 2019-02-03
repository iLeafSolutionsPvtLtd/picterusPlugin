#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

@interface PicterusCameraView : UIView<FlutterPlatformView>
{
}

-(id) initWithFrame:(CGRect)frame
     viewIdentifier:(int64_t)viewId
          arguments:(id _Nullable)args;

-(UIView*) view;

@end

@interface PicterusCameraViewFactory : NSObject<FlutterPlatformViewFactory>
{
}

-(NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                  viewIdentifier:(int64_t)viewId
                                       arguments:(id _Nullable)args;
@end
