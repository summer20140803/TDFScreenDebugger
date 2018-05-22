//
//  TDFSDMemoryLeakDetector.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import "TDFSDMemoryLeakDetector.h"
#import "TDFSDMLDGeneralizedProtocol.h"
#import "TDFSDMLDGeneralizedProxy.h"
#import "NSObject+SDMemoryLeakDetection.h"
#import "TDFSDQueueDispatcher.h"
#import "TDFSDPersistenceSetting.h"
#import "UIViewController+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>

const  NSString * SDMLDMemoryLeakDetectionDidStartNotificationName                 =  @"sd_mld_memoryLeakDetection_didStart";
const  NSString * SDMLDMemoryLeakDetectionDidFindSuspiciousLeakerNotificationName  =  @"sd_mld_memoryLeakDetection_didFindSuspiciousLeaker";
const  CGFloat    SDMLDMemoryLeakDetectionTimerInterval  =  0.5f;

@interface TDFSDMemoryLeakDetector ()

@property (nonatomic, strong) NSMutableArray<NSString *> *mld_cacheSingletonClassNames;
@property (nonatomic, strong) NSTimer *detectionTimer;

@end

@implementation TDFSDMemoryLeakDetector

@dynamic cacheSingletonClassNames;

static TDFSDMemoryLeakDetector *sharedInstance = nil;

static NSString *mld_warnningMessage(id leaker) {
    return [NSString stringWithFormat:@"[TDFScreenDebugger.MemoryLeakDetector] \n find a object \n (%@) \n may lead to memory leak \n (ps: this message will not show again unless restart app)", leaker];
}

#pragma mark - life cycle
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __weak NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        __block id noti_observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            if ([TDFSDPersistenceSetting sharedInstance].allowMemoryLeaksDetectionFlag) {
                [[TDFSDMemoryLeakDetector sharedInstance] thaw];
            }
            [center removeObserver:noti_observer];
        }];
    });
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!sharedInstance) {
        sharedInstance = [super allocWithZone:zone];
    }
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.mld_cacheSingletonClassNames = @[].mutableCopy;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFindLeakNotification:) name:(NSString *)SDMLDMemoryLeakDetectionDidFindSuspiciousLeakerNotificationName object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)SDMLDMemoryLeakDetectionDidFindSuspiciousLeakerNotificationName object:nil];
}

#pragma mark - TDFSDFunctionIOControlProtocol
- (void)thaw {
    [UINavigationController prepareForDetection];
    [UIViewController prepareForDetection];
    [UIView prepareForDetection];
    
    self.detectionTimer = [NSTimer scheduledTimerWithTimeInterval:SDMLDMemoryLeakDetectionTimerInterval target:self selector:@selector(sendDetectionStartNotification) userInfo:nil repeats:YES];
}

- (void)freeze {
    [self.detectionTimer invalidate];
    self.detectionTimer = nil;
}

#pragma mark - interface methods
- (NSArray<NSString *> *)cacheSingletonClassNames {
    return [self.mld_cacheSingletonClassNames copy];
}

- (void)addSingletonClassNameToCache:(NSString *)className {
    @synchronized(self) {
        [self.mld_cacheSingletonClassNames addObject:className];
    }
}

#pragma mark - private
- (void)sendDetectionStartNotification {
    sd_dispatch_async_to_main_queue(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)SDMLDMemoryLeakDetectionDidStartNotificationName object:nil];
    });
}

- (void)didReceiveFindLeakNotification:(NSNotification *)aNotification {
    TDFSDMLDGeneralizedProxy *proxy = [aNotification object];
    id leaker = proxy.weakTarget;
    if (leaker) {
        switch ([TDFSDMemoryLeakDetector sharedInstance].warnningType) {
            case SDMLDWarnningTypeAlert : {
                @weakify(self)
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"memory leak warnning" message:mld_warnningMessage(leaker) preferredStyle:UIAlertControllerStyleAlert];
                @weakify(alertC)
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(alertC)
                    [alertC dismissViewControllerAnimated:YES completion:nil];
                }];
                UIAlertAction *infoAction = [UIAlertAction actionWithTitle:@"Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(self)
                    UIAlertController *infoAlertC = [UIAlertController alertControllerWithTitle:@"info" message:[self trackInfoWithLeakerProxy:proxy] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [infoAlertC addAction:cancelAction];
                    [[[UIApplication sharedApplication].keyWindow.rootViewController sd_obtainTopViewController] presentViewController:infoAlertC animated:YES completion:nil];
                }];
                [alertC addAction:cancelAction];
                [alertC addAction:infoAction];
                [[[UIApplication sharedApplication].keyWindow.rootViewController sd_obtainTopViewController] presentViewController:alertC animated:YES completion:nil];
            } break;
            case SDMLDWarnningTypeConsole : {
                NSString *trackInfo = [NSString stringWithFormat:@"⚠️ %@ ⚠️", mld_warnningMessage(leaker)];
                NSLog(@"%@", trackInfo);
            } break;
            case SDMLDWarnningTypeException : {
                NSException *ex = [NSException exceptionWithName:NSGenericException reason:mld_warnningMessage(leaker) userInfo:nil];
                @throw ex;
            } break;
        }
    }
}

- (NSString *)trackInfoWithLeakerProxy:(TDFSDMLDGeneralizedProxy *)leakerProxy {
    id leaker = leakerProxy.weakTarget;
    if ([leaker isKindOfClass:[UIViewController class]]) {
        UIViewController *leakingViewController = leaker;
        NSString *title = leakingViewController.title;
        if (title.length) {
            return [NSString stringWithFormat:@"leaking viewController title : \"%@\"", title];
        } else {
            return @"no extra info";
        }
    } else if ([leaker isKindOfClass:[UIView class]]) {
        if (leakerProxy.weakViewControllerOwnerClassName.length) {
            return [NSString stringWithFormat:@"leaking view owner classname : \"%@\"\nleaking view owner title : \"%@\"", leakerProxy.weakViewControllerOwnerClassName, leakerProxy.weakViewControllerOwnerTitle];
        } else {
            return @"no extra info";
        }
    } else {
        if (leakerProxy.weakTargetOwnerName.length) {
            return [NSString stringWithFormat:@"leaking object classname : \"%@\"\nleaking object owner classname : \"%@\"", NSStringFromClass([leaker class]), leakerProxy.weakTargetOwnerName];
        } else {
            return @"no extra info";
        }
    }
}

@end
