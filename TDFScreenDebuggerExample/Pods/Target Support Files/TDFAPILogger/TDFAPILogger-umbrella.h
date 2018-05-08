#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TDFALBaseModel.h"
#import "TDFALRequestModel.h"
#import "TDFALResponseModel.h"
#import "TDFAPILogger.h"

FOUNDATION_EXPORT double TDFAPILoggerVersionNumber;
FOUNDATION_EXPORT const unsigned char TDFAPILoggerVersionString[];

