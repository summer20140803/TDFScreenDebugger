//
//  TDFSDCCCrashModel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/14.
//

#import "TDFSDCCCrashModel.h"
#import <objc/runtime.h>

@implementation TDFSDCCCrashModel

static  NSString * kSDCrashModelPersistenceKeyExceptionTime       = @"exceptionTime";
static  NSString * kSDCrashModelPersistenceKeyExceptionType       = @"exceptionType";
static  NSString * kSDCrashModelPersistenceKeyExceptionName       = @"exceptionName";
static  NSString * kSDCrashModelPersistenceKeyExceptionReason     = @"exceptionReason";
static  NSString * kSDCrashModelPersistenceKeyFuzzyLocalization   = @"fuzzyLocalization";
static  NSString * kSDCrashModelPersistenceKeyExceptionCallStack  = @"exceptionCallStack";

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[Time]\n%@\n\n[Type]\n%@\n\n[Name]\n%@\n\n[Reason]\n%@\n\n[Localization]\n%@\n\n[CallStack]\n%@", self.exceptionTime, self.exceptionType, self.exceptionName, self.exceptionReason, self.fuzzyLocalization, self.exceptionCallStack];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"\n\n--------------------[TDFScreenDebugger]--------------------\n[Time]  %@\n[Type]  %@\n[Name]  %@\n[Reason]  %@\n[Localization]  %@\n[CallStack]\n%@\n", self.exceptionTime, self.exceptionType, self.exceptionName, self.exceptionReason, self.fuzzyLocalization, self.exceptionCallStack];
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _exceptionTime      = [aDecoder decodeObjectForKey:kSDCrashModelPersistenceKeyExceptionTime];
        _exceptionType      = [aDecoder decodeObjectForKey:kSDCrashModelPersistenceKeyExceptionType];
        _exceptionName      = [aDecoder decodeObjectForKey:kSDCrashModelPersistenceKeyExceptionName];
        _exceptionReason    = [aDecoder decodeObjectForKey:kSDCrashModelPersistenceKeyExceptionReason];
        _fuzzyLocalization  = [aDecoder decodeObjectForKey:kSDCrashModelPersistenceKeyFuzzyLocalization];
        _exceptionCallStack = [aDecoder decodeObjectForKey:kSDCrashModelPersistenceKeyExceptionCallStack];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_exceptionTime      forKey:kSDCrashModelPersistenceKeyExceptionTime];
    [aCoder encodeObject:_exceptionType      forKey:kSDCrashModelPersistenceKeyExceptionType];
    [aCoder encodeObject:_exceptionName      forKey:kSDCrashModelPersistenceKeyExceptionName];
    [aCoder encodeObject:_exceptionReason    forKey:kSDCrashModelPersistenceKeyExceptionReason];
    [aCoder encodeObject:_fuzzyLocalization  forKey:kSDCrashModelPersistenceKeyFuzzyLocalization];
    [aCoder encodeObject:_exceptionCallStack forKey:kSDCrashModelPersistenceKeyExceptionCallStack];
}

#pragma mark - Override
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    TDFSDCCCrashModel *crashModel = object;
    if ([[self description] isEqualToString:[crashModel description]]) {
        return YES;
    }
    return NO;
}

@end
