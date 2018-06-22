


## 前言
**Blog Post：**[iOS真机桌面级调试工具 - TDFScreenDebugger](https://summer20140803.github.io/2018/05/20/iOS真机桌面级调试工具/)

其实这个组件一年前就开始投入精力去做了，只不过由于有时候公司项目忙，自己也懒，所以中间写写停停，所幸还存有点毅力和余力，终于在这段时间实现完一个还算稳定的版本了。下面先晒一下整个组件的架构设计。
![](https://ws3.sinaimg.cn/large/006tNc79gy1fsiwa7ubzvj30nn0bygm9.jpg)
可以看到，TDFScreenDebugger主体下拥有`API日志`、`Apple系统日志`、`野指针排查`、`自动化崩溃捕获`、`内存泄漏检测`、`循环引用`、`APM性能监控`、`User Tracting`等附属模块。其中`User Tracing`是未来一段时间将要扩展的一个模块，用于`协助观察用户行为轨迹`，暂时还没有接入。  

TDFScreenDebugger希望能帮助一部分程序猿更好地与测试人员和谐相处，增强发现程序问题和追溯问题根源的能力。

## 设计初衷
* 17年年初的采购平台支付三期项目接入微信支付对接银联时因为时间戳位长问题导致密钥匹配不成功，真机上调试了老半天，因为无法查看真机日志的原因，统一支付组件的调试作用大大缩小时
* 至少两次因为服务端接口改造导致业务页面显示异常而为此错背了锅时
* 提测后有一次我的手机调试无论如何都没问题而测试的手机随便怎么操作都能崩溃时
* 测试甩给你一个偶现的Crash然后就没有然后时

上述这些经历都成为了激发我设计与实现这个组件的动力。

## TDFScreenDebugger主体的设计
TDFScreenDebugger本体负责各大附属模块的协作、动效与性能优化工作。具体分为
* 负责维护一套DispatchQueuePool，因为附属组件很多都有自己的常驻监控需求，因此可以充分利用多核优势
* 部分展示数据(APM为主)的更新采用异步绘制渲染的机制
* flowlayout动画设计以及一些视图细节优化

接下来简单介绍一下各大附属功能模块。

## API日志模块
API日志模块内部实现借鉴了`AFNetworking`作者`mattt`针对AFNetworking网络库设计的协作组件`AFNetworkActivityLogger`的原理，通过注册监听AFNetworking库的
`AFNetworkingTaskDidResumeNotification`、`AFNetworkingTaskDidCompleteNotification`
这两个通知来进行API`起飞`和`着陆`动作完成后的元素提取和日志加工。

解决了AFNetworkActivityLogger的三大缺陷。
- 中文的unicode字符UTF-8化
- Pretty-Format
- 图片上传时的BodyStream处理

具体细节参见[这里](https://summer20140803.github.io/2017/08/15/制作API日志阅读器/)

## Apple系统日志模块
oc中最常见的`NSLog`操作会同时将`标准的Error`输出到控制台和系统日志(syslog)中(c的printf系列函数并不会，swift的printf为了保证性能也只会在模拟器环境中输出)。其内部是使用`Apple System Logger`(简称ASL)去实现的，ASL是苹果自己实现的用于输出日志到系统日志库的一套API接口，有点类似于SQL操作。在iOS真机设备上，使用ASL记录的log被缓存在沙盒文件中，直到设备被重启。

然后一开始我想的是自己维护一个GCD定时器不断异步地去跑ASL的API去日志库去取日志，但是始终觉得这样定时获取日志的频率太快的话会影响性能，而太慢的话又不能达到如期的效果。然后后来看`CocoaLumberjack`源码的时候发现苹果居然会在ASL更新日志DB的时候发出

```objc
#define  kNotifyASLDBUpdate   “com.apple.system.logger.message"
```
这样的跨进程的通知，然后自己改为这种方式注册了一下，瞬间整个人就非常舒服了。

但随着iOS10之后苹果弃用ASL，需要有一种兼容iOS10以上的解决方案。  

最终选用了GCD+dup2+pip的协作解决方案实现。  

具体细节参见[这里](https://summer20140803.github.io/2017/09/06/Apple系统日志捕获方案/)

## 自动化崩溃捕获模块
**Q：那么我们的项目中是否需要一套无比安全的Crash防护机制呢？**   
当然需要，但是不能在研发阶段。我认为研发阶段如果注入了crash防护机制会造成依赖心理，降低对崩溃风险的敏感度，并且对于很多数据导致的崩溃，一旦带到线上环境，数据发生了异常，发生了重大经济损失，这将会让我们得不偿失。  

**Q：那么我们的项目是否需要一套崩溃日志上报的机制呢？**     
当然也是需要的，现在市面上的崩溃统计SDK繁多，友盟、Bugly、Fabric、PLCrashReporter等都是这一类的。他们通常将崩溃信息日志上传到对应的服务器上，然后做一些事后统计和分析工作。  

**Q：那么在前面两者机制下，是否还需要别的机制用以帮助我们更好的避免线上崩溃和优化产品迭代效率呢？**     
我觉得还需要一款用于研发和提测阶段，可以在崩溃现场或第一时间捕获崩溃信息，然后将崩溃堆栈信息及时反馈给开发者的App内置组件，这尤其会大大增加提测后测试和开发人员沟通以及定位崩溃的效率。   

**实现思路：**  
  
- mach异常、signal信号 ->   
signal(machSignal, &machSignalExceptionHandler);   

-  NSException ->   
NSSetUncaughtExceptionHandler(&ocExceptionHandler);  

具体细节参见[这里](https://summer20140803.github.io/2017/11/23/iOS的崩溃捕获方案/)

## 野指针排查模块
通过效仿Xcode 的`Zombie Objects`这一机制，我们可以利用dealloc方法会自动实现父类的dealloc方法的特性，hook住`NSObject`和`NSProxy`两个oc的根类的dealloc方法，然后在调剂方法中将本来即将释放的对象的`isa指针`改为指向我们创建的一个新的僵尸类，然后外界对这个僵尸类发送任何消息(`objc_msgSend`)都会向程序发送我们手动抛出的应用级异常-NSException，然后在抛出的异常的`reason`中我们将非法调用对象的实际类型和调用方法输出，帮助使用者更好地定位野指针错误的根源。  

因为考虑到这个僵尸类需要在接收到任何消息的时候抛出我们预设的NSException异常，所以我们需要将这个类的`Automatic Reference Counting`设置成NO，即`MRC`模式。  

最后我们需要一个`对象缓存池机制`，在内存过高收到系统通知或达到预设的阈值时将自动将那些僵尸类对象isa指针还原成原来的类并调用`根类`原本的dealloc方法实现来正确地释放资源。

具体细节参见[这里](https://summer20140803.github.io/2017/12/25/iOS使用代码排查野指针错误/)

## APM性能监控模块
应用CPU占用、应用内存占用、FPS帧数这三项监控的教程网上都有，原理就是跑定时器(CPU/内存不用跟屏幕刷新率一致的CADisplayLink，FPS帧数监控需要)  

多提一下卡顿(LAG)监控。  

网上推崇的一种方案是在子线程中异步注册监听Runloop的所有Activity事件，类似于这样 
  
```objc
CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                            kCFRunLoopAllActivities,
                            YES,
                            0,
                            &runloopObserverCallBack,
                            &context);
CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
```

然后通过检测`kCFRunLoopBeforeSources`与`kCFRunLoopAfterWaiting`之间和`kCFRunLoopAfterWaiting`之后的时间间隔来判断`主Runloop`处理事务的时间。如果大于预设的阈值，则被视为发生了一次卡顿。

后来我发现这种方案有一个不能容忍的瑕疵：即手指在scrollView及子类视图上(列表)持续保持滑动姿势的时候，主Runloop始终处于`kCFRunLoopBeforeWaiting`的活动状态，这时候就算列表卡出天际了也没用。  

后来决定换一种方案。  

首先开启一个`线程X`，在线程X中创建一个loop循环和一个标记位，然后派发一个任务到UI线程，任务中会将`标记位`状态修改，然后线程X就滚去`睡觉`，睡觉时间为我们预设的一个时间间隔阈值，等到线程X醒来之后立马检测标志位状态是否发生了状态，如果没有改变，说明UI线程非常忙，没空处理线程X派发的任务，意味着UI线程因为处理大量计算而产生了视觉上的卡顿。我会在这些卡顿发生同时，dump下这一时刻的`堆栈信息`，然后保存下来并通知使用者。  

这种方案可以解决网上比较普及的卡顿监控方案的瑕疵，但是也有一些缺陷。最直观的一个缺陷是当我们在Xcode中调试打断点时，程序处于`trap`中，并不能继续处理UI线程上的任务，所以此时也会错误地发出卡顿警告。

## 内存泄漏模块
大致沿用了`PLeakingSniffer`的实现思路，优化了PLeakingSniffer的一些细节上的问题，算是PLeakingSniffer的一种改进方案。

* 以UIViewController的子类为树根结点的子结点检测将会包含数组等基础集合数据结构，因为这些结构的元素一样是被强引用的，应该被包含在检测对象的范围中。(NSPointerArray、NSMapTable、NSHashTable除外)
* 会自动排除一个结点下的单例对象的强引用，这种属于错误检测判断。
* 将除集合数据结构外的其他苹果框架中的类剔除到检测范围之外，增强检测的性能。
* 提供Alert、Console、Exception三种可疑提示方式。

## 循环引用模块
Facebook大厂出品的[FBRetainCycleDetector](https://github.com/facebook/FBRetainCycleDetector)已足够优秀，所以这个模块只需要帮助接入，然后做一些自动化的配置和触发控制即可。

## 关于未来
上文提到了，在未来一段时间，博主会在User Tracing方面进行深入研究和试验。除此之外，争取能引入更多的实用黑科技来帮助我们一起打造更加完美的应用🤓。  

并且如果你们有好的提议或者基于上述模块有更优的实现思路的话，可以在文下评论或私下与我分享交流(summer20140803@gmail.com)~

