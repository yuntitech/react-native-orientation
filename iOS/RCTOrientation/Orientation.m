//
//  Orientation.m
//

#import "Orientation.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif

static NSString *const BKLiOSDeviceOrientationDidChangeNotification = @"cn.bookln.iOSDeviceOrientationDidChange";
@interface Orientation()
@property(nonatomic, assign) BOOL supportForOrientationChange;
@end
@implementation Orientation
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
    _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
    return _orientation;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
#ifdef DEBUG
        NSLog(@"设备方向 orientation: %ld", orientation);
#else
#endif
        [wself.bridge.eventDispatcher sendDeviceEventWithName:@"specificOrientationDidChange"
                                                         body:@{@"specificOrientation": [wself getSpecificOrientationStr:orientation]}];
        
        [wself.bridge.eventDispatcher sendDeviceEventWithName:BKLiOSDeviceOrientationDidChangeNotification
                                                         body:@{@"orientation": [wself getOrientationStr:orientation]}];
    });
}


- (NSString *)getOrientationStr: (UIDeviceOrientation)orientation {
    NSString *orientationStr;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationStr = @"PORTRAIT";
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            
            orientationStr = @"LANDSCAPE";
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientationStr = @"PORTRAITUPSIDEDOWN";
            break;
            
        default:
            // orientation is unknown, we try to get the status bar orientation
            switch ([[UIApplication sharedApplication] statusBarOrientation]) {
                case UIInterfaceOrientationPortrait:
                    orientationStr = @"PORTRAIT";
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    
                    orientationStr = @"LANDSCAPE";
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientationStr = @"PORTRAITUPSIDEDOWN";
                    break;
                    
                default:
                    orientationStr = @"UNKNOWN";
                    break;
            }
            break;
    }
    return orientationStr;
}

- (NSString *)getSpecificOrientationStr: (UIDeviceOrientation)orientation {
    NSString *orientationStr;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationStr = @"PORTRAIT";
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            orientationStr = @"LANDSCAPE-LEFT";
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orientationStr = @"LANDSCAPE-RIGHT";
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientationStr = @"PORTRAITUPSIDEDOWN";
            break;
            
        default:
            // orientation is unknown, we try to get the status bar orientation
            switch ([[UIApplication sharedApplication] statusBarOrientation]) {
                case UIInterfaceOrientationPortrait:
                    orientationStr = @"PORTRAIT";
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    
                    orientationStr = @"LANDSCAPE";
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientationStr = @"PORTRAITUPSIDEDOWN";
                    break;
                    
                default:
                    orientationStr = @"UNKNOWN";
                    break;
            }
            break;
    }
    return orientationStr;
}

#pragma mark - event response
- (void)handleLockToPortrait
{
#if DEBUG
    NSLog(@"Locked to Portrait");
#endif
    if (self.supportForOrientationChange) {
        [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
    } else {
        [Orientation setOrientation:UIInterfaceOrientationMaskPortrait];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        if (@available(iOS 13.0, *)) {
            // 修复屏幕旋转的 bug
            NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
            [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        }
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }];
}

- (void)handleLockToLandscapeLeft
{
#if DEBUG
    NSLog(@"Locked to Landscape Left");
#endif
    if (self.supportForOrientationChange) {
        [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
    } else {
        [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
    }];
}

- (void)handleLockToLandscapeRight
{
#if DEBUG
    NSLog(@"Locked to Landscape Right");
#endif
    if (self.supportForOrientationChange) {
        [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
    } else {
        [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeRight];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        // this seems counter intuitive
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }];
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback) {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        NSString *orientationStr = [wself getOrientationStr:orientation];
        callback(@[[NSNull null], orientationStr]);
    });
}

RCT_EXPORT_METHOD(getSpecificOrientation:(RCTResponseSenderBlock)callback) {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        NSString *orientationStr = [wself getSpecificOrientationStr:orientation];
        callback(@[[NSNull null], orientationStr]);
    });
}

RCT_EXPORT_METHOD(lockToPortrait)
{
    [self handleLockToPortrait];
}

RCT_EXPORT_METHOD(lockToLandscape)
{
#if DEBUG
    NSLog(@"Locked to Landscape");
#endif
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getSpecificOrientationStr:orientation];
    if ([orientationStr isEqualToString:@"LANDSCAPE-LEFT"]) {
        if (self.supportForOrientationChange) {
            [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
        } else {
            [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        }];
    } else {
        if (self.supportForOrientationChange) {
            [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
        } else {
            [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        }];
    }
}



RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
    [self handleLockToLandscapeLeft];
}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
    [self handleLockToLandscapeRight];
}

RCT_EXPORT_METHOD(unlockAllOrientations)
{
#if DEBUG
    NSLog(@"Unlock All Orientations");
#endif
    [Orientation setOrientation:UIInterfaceOrientationMaskAll];
}

/**
 支持所有方向
 */
RCT_EXPORT_METHOD(supportForAllOrientations:(BOOL)supportAllOrientations)
{
    self.supportForOrientationChange = supportAllOrientations;
}

- (NSDictionary *)constantsToExport
{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getOrientationStr:orientation];
    
    return @{
        @"initialOrientation": orientationStr
    };
}

@end
