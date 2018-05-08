//
//  TDFSDQueueDispatcher.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/17.
//

#import <Foundation/Foundation.h>


//NSQualityOfService枚举定义了以下值：
//* UserInteractive：和图形处理相关的任务，比如滚动和动画。
//* UserInitiated：用户请求的任务，但是不需要精确到毫秒级。例如，如果用户请求打开电子邮件App来查看邮件。
//* Utility：周期性的用户请求任务。比如，电子邮件App可能被设置成每五分钟自动检查新邮件。但是在系统资源极度匮乏的时候，将这个周期性的任务推迟几分钟也没有大碍。
//* Background：后台任务，用户可能并不会察觉对这些任务。比如，电子邮件App对邮件进行引索以方便搜索。


dispatch_queue_t sd_better_queue_by_qos(NSQualityOfService qos);

dispatch_queue_t sd_dispatch_async_by_qos(NSQualityOfService qos, dispatch_block_t block);

dispatch_queue_t sd_dispatch_async_by_qos_user_interactive(dispatch_block_t block);
dispatch_queue_t sd_dispatch_async_by_qos_user_initiated(dispatch_block_t block);
dispatch_queue_t sd_dispatch_async_by_qos_utility(dispatch_block_t block);
dispatch_queue_t sd_dispatch_async_by_qos_background(dispatch_block_t block);
dispatch_queue_t sd_dispatch_async_by_qos_default(dispatch_block_t block);

void sd_dispatch_async_to_main_queue(dispatch_block_t block);

void sd_dispatch_clean_context_by_specified_qos(NSQualityOfService qos);
void sd_dispatch_clean_current_contexts(void);

