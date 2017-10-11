//
//  TDFSDSearchBar.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/19.
//
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

CF_EXPORT const CGFloat SDSearchBarInputAccessoryHeight;

@interface TDFSDSearchBar : UISearchBar

@property (nonatomic, assign) NSUInteger currentSearchIndex;
@property (nonatomic, assign) NSUInteger searchResultTotalCount;

@property (nonatomic, strong) RACSubject *previousProxy;
@property (nonatomic, strong) RACSubject *nextProxy;

@property (nonatomic, strong, readonly) RACCommand *accessoryDelayCommand;

@property (nonatomic,   weak) UIView *hitTestView;

@end
