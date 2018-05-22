//
//  TDFSDPMZombieProxy.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/4/4.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFSDPMZombieProxy.h"

@implementation TDFSDPMZombieProxy

#define __ZombieBlew  [self zombieProxyBlew:_cmd]
#define __ZombieBlewWithSelector(selector)  [self zombieProxyBlew:selector]

#pragma mark - override
- (void)forwardInvocation:(NSInvocation *)invocation { __ZombieBlewWithSelector(invocation.selector); }
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel { __ZombieBlewWithSelector(sel); return nil; }

- (BOOL)isEqual:(id)object { __ZombieBlew; return NO; }
- (Class)class { __ZombieBlew; return nil; }
- (instancetype)self { __ZombieBlew; return nil; }
- (id)performSelector:(SEL)aSelector { __ZombieBlew; return nil; }
- (id)performSelector:(SEL)aSelector withObject:(id)object { __ZombieBlew; return nil; }
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 { __ZombieBlew; return nil; }
- (BOOL)isProxy { __ZombieBlew; return NO; }
- (BOOL)isKindOfClass:(Class)aClass { __ZombieBlew; return NO; }
- (BOOL)isMemberOfClass:(Class)aClass { __ZombieBlew; return NO; }
- (BOOL)conformsToProtocol:(Protocol *)aProtocol { __ZombieBlew; return NO; }
- (BOOL)respondsToSelector:(SEL)aSelector { __ZombieBlew; return NO; }
- (instancetype)retain { __ZombieBlew; return nil; }
- (oneway void)release { __ZombieBlew; }
- (instancetype)autorelease { __ZombieBlew; return nil; }
- (NSUInteger)retainCount { __ZombieBlew; return NSNotFound; }
- (struct _NSZone *)zone { __ZombieBlew; return NULL; };
- (void)dealloc { __ZombieBlew; [super dealloc]; }
- (NSString *)description { __ZombieBlew; return nil; }
- (NSString *)debugDescription { __ZombieBlew; return nil; }
- (NSUInteger)hash { __ZombieBlew; return NSNotFound; }
- (Class)superclass { __ZombieBlew; return nil; }

#pragma mark - private
- (void)zombieProxyBlew:(SEL)selector {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason: \
            [NSString stringWithFormat:@"[TDFScreenDebugger.PerformanceMonitor.WildPointerChecker] find a wild pointer error about \' message \" [%@ %@] \" was sent to a zombie object at address: %p \'", NSStringFromClass(self.originClass), NSStringFromSelector(selector), self] userInfo:nil];
}

@end
