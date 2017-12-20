//
//  TDFSDQueueDispatcher.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/17.
//

#import "TDFSDQueueDispatcher.h"
#import "TDFScreenDebuggerDefine.h"
#import <libkern/OSAtomic.h>

static const int  kSD_QUEUE_MAX_COUNT_FOR_EACH_QOS  =  32;

typedef struct {
    const char * name;
    void ** queues;
    uint32_t queueCount;
    int32_t offset;      // it's shared..
} SDDispatchContext;

static SDDispatchContext *contexts[5];

static SD_INLINE dispatch_queue_priority_t sd_qos_to_dispatch_priority(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUserInitiated: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUtility: return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceBackground: return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        case NSQualityOfServiceDefault: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
        default: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}

static SD_INLINE qos_class_t sd_qos_to_qos_class(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return QOS_CLASS_USER_INTERACTIVE;
        case NSQualityOfServiceUserInitiated: return QOS_CLASS_USER_INITIATED;
        case NSQualityOfServiceUtility: return QOS_CLASS_UTILITY;
        case NSQualityOfServiceBackground: return QOS_CLASS_BACKGROUND;
        case NSQualityOfServiceDefault: return QOS_CLASS_DEFAULT;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

static dispatch_queue_attr_t sd_qos_to_queue_attributes(NSQualityOfService qos) {
    dispatch_qos_class_t qosClass = sd_qos_to_qos_class(qos);
    return dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
};

static dispatch_queue_t sd_qos_to_dispatch_queue(NSQualityOfService qos, const char * queueName) {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        dispatch_queue_attr_t attr = sd_qos_to_queue_attributes(qos);
        return dispatch_queue_create(queueName, attr);
    } else {
        dispatch_queue_t queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(sd_qos_to_dispatch_priority(qos), 0));
        return queue;
    }
}

static SDDispatchContext * sd_dispatch_context_create(const char * name, uint32_t queueCount, NSQualityOfService qos) {
    SDDispatchContext *context = calloc(1, sizeof(SDDispatchContext));
    if (!context)  return NULL;
    
    context->queues = calloc(queueCount, sizeof(void *));
    if (context->queues == NULL) {
        free(context);
        return NULL;
    }
    for (int idx = 0; idx < queueCount; idx++) {
        context->queues[idx] = (__bridge_retained void *)sd_qos_to_dispatch_queue(qos, name);
    }
    context->queueCount = queueCount;
    if (name) {
        context->name = strdup(name);
    }
    context->offset = 0;
    return context;
}

static void sd_dispatch_context_release(SDDispatchContext *context) {
    if (context == NULL) return;
    if (context->name != NULL) free((void *)context->name);
    if (context->queues != NULL) {
        free(context->queues);
        context->queues = NULL;
    }
    free(context);
}

static dispatch_queue_t sd_dispatch_context_get_queue(SDDispatchContext *context) {
    uint32_t offset = (uint32_t)OSAtomicIncrement32(&context->offset);
    dispatch_queue_t queue = (__bridge dispatch_queue_t)context->queues[offset % context->queueCount];
    if (queue) return queue;
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

static SDDispatchContext * sd_dispatch_context_get_for_qos(NSQualityOfService qos) {
    int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
    count = MAX(1, MIN(count, kSD_QUEUE_MAX_COUNT_FOR_EACH_QOS));
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[0] = sd_dispatch_context_create("com.summer20140803.UserInteractive", count, qos);
            });
            return contexts[0];
        }
            
        case NSQualityOfServiceUserInitiated: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[1] = sd_dispatch_context_create("com.summer20140803.UserInitiated", count, qos);
            });
            return contexts[1];
        }
            
        case NSQualityOfServiceUtility: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[2] = sd_dispatch_context_create("com.summer20140803.Utility", count, qos);
            });
            return contexts[2];
        }
            
        case NSQualityOfServiceBackground: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[3] = sd_dispatch_context_create("com.summer20140803.Background", count, qos);
            });
            return contexts[3];
        }
            
        case NSQualityOfServiceDefault:
        default: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[4] = sd_dispatch_context_create("com.summer20140803.Default", count, qos);
            });
            return contexts[4];
        }
    }
}

dispatch_queue_t sd_better_queue_by_qos(NSQualityOfService qos) {
    SDDispatchContext *context = sd_dispatch_context_get_for_qos(qos);
    dispatch_queue_t queue = sd_dispatch_context_get_queue(context);
    return queue;
}

dispatch_queue_t sd_dispatch_async_by_qos(NSQualityOfService qos, dispatch_block_t block) {
    if (block == nil)  return NULL;
    dispatch_queue_t queue = sd_better_queue_by_qos(qos);
    dispatch_async(queue, block);
    return queue;
}

dispatch_queue_t sd_dispatch_async_by_qos_user_interactive(dispatch_block_t block) {
    return sd_dispatch_async_by_qos(NSQualityOfServiceUserInteractive, block);
}

dispatch_queue_t sd_dispatch_async_by_qos_user_initiated(dispatch_block_t block) {
    return sd_dispatch_async_by_qos(NSQualityOfServiceUserInitiated, block);
}

dispatch_queue_t sd_dispatch_async_by_qos_utility(dispatch_block_t block) {
    return sd_dispatch_async_by_qos(NSQualityOfServiceUtility, block);
}

dispatch_queue_t sd_dispatch_async_by_qos_background(dispatch_block_t block) {
    return sd_dispatch_async_by_qos(NSQualityOfServiceBackground, block);
}

dispatch_queue_t sd_dispatch_async_by_qos_default(dispatch_block_t block) {
    return sd_dispatch_async_by_qos(NSQualityOfServiceDefault, block);
}

void sd_dispatch_async_to_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        !block ?: block();
        return;
    }
    dispatch_async(dispatch_get_main_queue(), block);
}

void sd_dispatch_clean_context_by_specified_qos(NSQualityOfService qos) {
    SDDispatchContext *context = sd_dispatch_context_get_for_qos(qos);
    sd_dispatch_context_release(context);
}

void sd_dispatch_clean_current_contexts(void) {
    for (int idx = 0; idx < 5; idx ++) {
        SDDispatchContext *context = contexts[idx];
        if (context != NULL) {
            sd_dispatch_context_release(context);
        }
    }
}

