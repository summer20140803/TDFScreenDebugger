//
//  TDFSDDeveloperGuideController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/3/26.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFSDDeveloperGuideController.h"
#import "TDFSDTextView.h"
#import "TDFScreenDebuggerDefine.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>

@interface TDFSDDeveloperGuideController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) TDFSDTextView *guideDocView;

@end

@implementation TDFSDDeveloperGuideController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SD_DELAY_HANDLER(0.50f, {
        [self.guideDocView sd_fadeAnimationWithDuration:0.20f];
        self.guideDocView.text = \
        @" \
【显示与隐藏】 \n \
    · 当App启动后，通过`摇一摇`手势启动调试器(如果是Xcode模拟器，可以使用快捷键command+control+z)，默认会出现在屏幕右下角，再次`摇一摇`会隐藏调试器 \n\n \
【功能集】 \n \
    · 目前研发完整的功能有 离散API日志收集、绑定API日志收集、系统日志收集、崩溃拦截捕获、简易APM、额外性能监控工具集。 \n \
    · 目前尚在研发的功能有 循环引用探测、野指针监控。 \n \
    · 未来会设计出一些更加强大的功能，敬请期待。 \n\n \
【基本操作】 \n \
    · 通过`摇一摇`手势呼出调试器后，快速单点灯泡图标进入`工具集页面` \n \
    · 通过`摇一摇`手势呼出调试器后，长按1秒灯泡图标切换图标为`APM监控窗口`，再次长按即回到`调试器灯泡图标`，APM窗口内的参数详见`【APM窗口】`一览 \n \
    · 可以通过点击`工具集页面`右上角的齿轮图标进入`设置页面`，某些特殊参数作用详见`【特殊参数设置】`一览  \n\n \
【写给研发】 \n \
    · 调试器处于`灯泡`模式下，将有消息提醒功能，消息提醒数将在灯泡图标的右上角呈现，提醒类型默认为API未读提醒，可以通过`设置页面`更改消息提醒的类型 \n \
    · 当程序发生Crash后，调试器能在大部分情况下捕获抛出的异常(包括BSD层发出signal)，并在Crash现场立即弹出友好的`崩溃信息详情页面`以供开发第一时间发现导致崩溃的代码，但是由于崩溃后程序已处于不稳定状态，如果崩溃代码发生在多线程甚至更复杂的环境下，`崩溃信息详情页面`可能会弹出失败(也可能会出现假死的状态)，此时可以直接手动kill掉App，重启后通过点击工具集中的`Crash Captor`查看已被捕获的崩溃详情(如果是处于Xcode连接状态的真机或者模拟器也可以在Xcode控制台直接查看本工具辅助打印的崩溃堆栈信息) \n \
    · API日志收集在模拟器中通过快捷键在业务页面与调试器页面之间切换翻阅效率要高于Xcode与模拟器之间切换 \n\n \
【写给测试】 \n \
    · 工具已集成类似Charles的抓包功能，提测阶段可通过调试器工具集中的`API Recorder(binding)`查看网络请求的起飞和着陆信息，默认以时间先后排序，为了增强阅读性，信息已被格式化 \n \
    · 如果在提测阶段发现程序出现`崩溃信息详情页面`，即崩溃已被工具捕获，此时建议测试人员截屏并发送给对应的研发人员进行崩溃定位和代码修复，加快研发人员修复效率，如果不幸没能弹出`崩溃信息详情页面`，甚至程序出现假死状态，则建议手动kill掉App，重启后通过点击工具集中的`Crash Captor`查看已被捕获的崩溃详情，然后截屏或者直接交由研发人员更快定位和修复 \n\n \
【APM窗口】 \n \
    · <CPU> 当前App处于手机CPU的占比 \n \
    · <MEM> 当前App占用的手机运行内存(由于工具本身维护了一些监控线程，所以数据可能会有2MB左右的偏差) \n \
    · <FPS> 当前App UI线程的FPS帧数，最大60，低于20-25时说明可能会出现交互不流畅等卡顿现象 \n \
    · <LAG> 当前App在本次运行期间发生的卡顿数，点击后可查阅历史卡顿记录和发生时的辅助堆栈信息，卡顿规则和相关阈值可由`设置页面`指定 \n\n \
【特殊参数设置】 \n \
    以下为`设置页面`的一些特殊参数： \n \
    · <tolerableLagThreshold> 卡顿发生的判定阈值，如果主线程在一个特定时段延误了这个阈值，则被判定为发生了一次卡顿，默认为0.2秒 \n \
    · <fpsWarnningThreshold> FPS的警告判定阈值，如果当前调试器获取的FPS小于这个阈值，则会在APM窗口模式下通过醒目的暗红色闪烁提示使用者，FPS低于警告值，默认为30 \n \
    · <allowWildPointerMonitoring> 是否允许开启野指针监控，由于开启野指针监控，其内部的实现机制将会消耗一定的app内存，因此我们只希望使用者在发生了野指针错误并需要排查时开启，所以这个选项会在重启App时自动重置为关闭 \n\n \
【另外】 \n \
    如果发现了工具的问题或者有更好的建议，请联系作者<藕粉-oufen@2dfire.com> \n\n \
        ";
    })
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return SD_STRING(@"How to use");
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.guideDocView;
}

#pragma mark - getter
- (TDFSDTextView *)guideDocView {
    if (!_guideDocView) {
        _guideDocView = [[TDFSDTextView alloc] init];
        _guideDocView.textColor = [UIColor whiteColor];
        _guideDocView.font = [UIFont fontWithName:@"PingFang SC" size:13];
        _guideDocView.showsVerticalScrollIndicator = NO;
    }
    return _guideDocView;
}

@end
