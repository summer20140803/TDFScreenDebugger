
## Installation

    pod 'TDFScreenDebugger'

## Usage
Only use cocoapods `podfile` to import 'TDFScreenDebugger', then run `pod install` or `pod update`, everything is ready !

## 前言
**Blog Post：**[iOS真机桌面级调试工具 - TDFScreenDebugger](https://summer20140803.github.io/2018/05/20/iOS真机桌面级调试工具/)

其实这个组件一年前就开始投入精力去做了，只不过由于有时候公司项目忙，自己也懒，所以中间写写停停，所幸还存有点毅力和余力，终于在这段时间实现完一个还算稳定的版本了。下面先晒一下整个组件的架构设计。
![](https://ws3.sinaimg.cn/large/006tNc79gy1fsiwa7ubzvj30nn0bygm9.jpg)

可以看到，TDFScreenDebugger主体下拥有`API日志`、`Apple系统日志`、`野指针排查`、`自动化崩溃捕获`、`内存泄漏检测`、`循环引用`、`APM性能监控`、`User Tracting`等附属模块。其中`User Tracing`是未来一段时间将要扩展的一个模块，用于`协助观察用户行为轨迹`，暂时还没有接入。  

TDFScreenDebugger希望能帮助一部分程序猿更好地与测试人员和谐相处，增强发现程序问题和追溯问题根源的能力。

## 设计初衷
* 公司项目支付对接第三方清算平台时因为时间戳位长问题导致密钥匹配不成功，真机上调试了老半天，因为无法查看真机日志的原因，调试效率down
* 至少两次因为服务端接口改造导致业务页面显示异常而为此错背了锅
* 提测后有一次我的手机调试无论如何都没问题而测试的手机随便怎么操作都能崩溃
* 测试甩给你一个偶现的Crash然后就没有然后了

上述这些经历都成为了激发我设计与实现这个组件的动力。

## TDFScreenDebugger主体的设计
TDFScreenDebugger本体负责各大附属模块的协作、动效与性能优化工作。具体分为
* 负责维护一套DispatchQueuePool，因为附属组件很多都有自己的常驻监控需求，因此可以充分利用多核优势
* 部分展示数据(APM为主)的更新采用异步绘制渲染的机制
* flowlayout动画设计以及一些视图细节优化

接下来简单介绍一下各大附属功能模块的功能。

## API日志模块
- 中文的unicode字符UTF-8化
- Pretty-Format
- 图片上传时的BodyStream处理
- 支持日志内容的关键词实时搜索
- API新日志`消息提醒
- 可以删除现有的日志内容
- 提供 离散型 和 绑定型 日志视图，通过特定手势(默认为摇一摇)直接在业务视图与API日志模块之间切换，使用比抓包工具更加便捷

## Apple系统日志模块
- 与API日志作分离，更加干净
- 支持日志内容的关键词实时搜索
- 可以删除现有的日志内容
- 通过特定手势(默认为摇一摇)直接在业务视图与Apple系统日志模块之间切换，在Xcode模拟器上甚至比切换到Xcode控制台查看日志还方便

## 自动化崩溃捕获模块
- 默认自动捕获，无须配置
- 支持mach、signal、NSException等Crash类型
- Crash现场直接弹出友好视图提示开发者，并携带对应的堆栈信息，通过正则帮你更快定位Crash根源代码
- 支持安全(提示推迟到下一次App启动后)与非安全捕获模式(Crash现场直接弹出提示视图)
- 支持回看崩溃历史与对应的崩溃原因

## 野指针排查模块
- 默认为关闭状态，开启后跑到可疑的野指针视图即可快速定位野指针错误
- 定位到的野指针错误会通过携带调用野指针的对象相关信息帮助开发者更快定位，配合`自动化崩溃捕获模块`弹出友好视图

## APM性能监控模块
- 检测含应用内存占用、应用CPU占用、视图FPS帧数变化、视图卡顿等多项监控数据
- 视图FPS帧数低于警告阈值 或 视图卡顿发生时自动有警告高光提示 
- 监控数据的实时更新采用异步绘制渲染的方式，对主线程影响非常小
- 可以回溯发生卡顿时的堆栈信息

## 内存泄漏模块
此模块沿用PLeakingSniffer的设计思想，算是一种PLeakingSniffer的改进方案，除PLeakingSniffer自身的一些优点外，还在以下方面进行了优化。
* 以UIViewController的子类为树根结点的子结点检测将会包含数组等基础集合数据结构，因为这些结构的元素一样是被强引用的，应该被包含在检测对象的范围中。(NSPointerArray、NSMapTable、NSHashTable除外)
* 会自动排除一个结点下的单例对象的强引用，这种属于错误检测判断。
* 将除集合数据结构外的其他苹果框架中的类(不包括NSTimer类)剔除到检测范围之外，增强检测的性能。
* 提供Alert、Console、Exception三种可疑提示方式。

## 循环引用模块
Facebook大厂出品的[FBRetainCycleDetector](https://github.com/facebook/FBRetainCycleDetector)已足够优秀，所以这个模块只负责封装与接入，然后做一些自动化的配置和触发控制。

## 关于未来
上文提到了，在未来一段时间，博主会在User Tracing方面进行深入研究和试验。除此之外，争取能引入更多的实用黑科技来帮助我们一起打造更加完美的应用🤓。  

并且如果你们有好的提议或者基于上述模块有更优的实现思路的话，可以在文下评论或私下与我分享交流(summer20140803@gmail.com)~

