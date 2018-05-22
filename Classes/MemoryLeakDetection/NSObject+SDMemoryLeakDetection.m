//
//  NSObject+SDMemoryLeakDetection.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import "NSObject+SDMemoryLeakDetection.h"
#import "TDFSDMLDGeneralizedProxy.h"
#import "TDFSDMemoryLeakDetector.h"
#import <objc/runtime.h>

@implementation NSObject (SDMemoryLeakDetection)

@dynamic mld_proxy;

+ (void)prepareForDetection {}

- (void)bindWithProxy {
    if (self.mld_proxy) return;
    
    // skip system classes
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    if (![bundle isEqual:[NSBundle mainBundle]]) {
        return;
    }

    // skip view which doesn't be added to superview
    if ([self isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self;
        if (view.superview == nil) {
            return;
        }
    }

    // skip controller which just be held strongly
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *controller = (UIViewController *)self;
        if (controller.navigationController == nil && controller.presentingViewController == nil && controller != [UIApplication sharedApplication].keyWindow.rootViewController) {
            return;
        }
    }
    
    TDFSDMLDGeneralizedProxy *proxy = [TDFSDMLDGeneralizedProxy proxyWithTarget:self];
    [self setMld_proxy:proxy];
}

- (BOOL)isSuspiciousLeaker {
    if ([TDFSDMemoryLeakDetector sharedInstance].customizedObjectIsLeakingLogicHandler) {
        return [[TDFSDMemoryLeakDetector sharedInstance] customizedObjectIsLeakingLogicHandler](self);
    } else {
        BOOL isSuspiciousLeaker = NO;
        if (self.mld_proxy.weakTargetOwner == nil) {
            isSuspiciousLeaker = YES;
        }
        return isSuspiciousLeaker;
    }
}

- (void)trackAllStrongPropsLeaks {
    Class class = [self class];
    NSBundle *bundle = [NSBundle bundleForClass:class];
    if (![bundle isEqual:[NSBundle mainBundle]]) {
        return;
    }
    
    NSMutableArray *allStrongProps = @[].mutableCopy;
    while ([[NSBundle bundleForClass:class] isEqual:[NSBundle mainBundle]]) {
        NSArray *strongProps = [self mld_getAllPropertyNames:class];
        [allStrongProps addObjectsFromArray:strongProps];
        class = [class superclass];
    }
    
    [allStrongProps enumerateObjectsUsingBlock:^(NSString * _Nonnull propName, NSUInteger idx, BOOL * _Nonnull stop) {
        id obj = [self valueForKey:propName];
        if (obj) {
            [obj bindWithProxy];
            [obj mld_proxy].weakTargetOwner = self;
            Class class = [self class];
            if ([class isKindOfClass:[UIViewController class]]) {
                UIViewController *vc = (UIViewController *)self;
                [obj mld_proxy].weakViewControllerOwnerClassName = NSStringFromClass([vc class]);
                [obj mld_proxy].weakViewControllerOwnerTitle = vc.title;
            } else {
                [obj mld_proxy].weakTargetOwnerName = NSStringFromClass([self class]);
            }
            
            [obj trackAllStrongPropsLeaks];
        }
    }];
}

- (NSArray *)mld_getAllPropertyNames:(Class)cls {
    unsigned int i, count = 0;
    
    objc_property_t *properties = class_copyPropertyList(cls, &count );
    
    if (count == 0) {
        free(properties);
        return nil;
    }
    
    NSMutableArray* names = @[].mutableCopy;
    
    for (i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        
        NSString *typeName = @"";
        const char* str = mld_property_getTypeString(property);
        if (str != NULL) {
            typeName = [NSString stringWithUTF8String:str];
            
            if (![typeName containsString:@"T@"])  continue;
            if ([typeName isEqualToString:@"T@"] || [typeName isEqualToString:@"T@?"]) {
                goto nextStep_FilterStrongProps;
            }
            // such as ` @"T@\n"NSTimer\"" `, we filter out some classes which we don't need to detect
            NSString *className = [typeName substringWithRange:NSMakeRange(3, typeName.length - 4)];
            Class propClass = NSClassFromString(className);
            if (propClass != NULL) {
                NSBundle *bundle = [NSBundle bundleForClass:propClass];
                if (![bundle isEqual:[NSBundle mainBundle]]) {
                    continue;
                }
            }
        }
        
nextStep_FilterStrongProps:;
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        bool isStrong = mld_isStrongProperty(property);
        if (isStrong == NO)  continue;
        
        [names addObject:name];
    }
    
    return names;
}

bool mld_isStrongProperty(objc_property_t property) {
    const char* attrs = property_getAttributes( property );
    if (attrs == NULL)  return false;
    
    const char* p = attrs;
    p = strchr(p, '&');
    if (p == NULL) {
        return false;
    }
    else {
        return true;
    }
}

const char*  mld_property_getTypeString( objc_property_t property ) {
    const char * attrs = property_getAttributes( property );
    if (attrs == NULL)  return NULL;
    
    static char buffer[256];
    const char * e = strchr( attrs, ',' );
    if (e == NULL)  return NULL;
    
    int len = (int)(e - attrs);
    memcpy(buffer, attrs, len);
    buffer[len] = '\0';
    
    return buffer;
}

#pragma mark - associated object
- (TDFSDMLDGeneralizedProxy *)mld_proxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMld_proxy:(TDFSDMLDGeneralizedProxy *)proxy {
    objc_setAssociatedObject(self, @selector(mld_proxy), proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
