//
//  Yodo1GDCTimer.m
//
//  Created by ibireme on 15/2/7.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "Yodo1GDCTimer.h"
#import <pthread.h>

#define YODO1_LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);


@implementation Yodo1GDCTimer {
    BOOL _valid;
    NSTimeInterval _timeInterval;
    BOOL _repeats;
    __weak id _target;
    SEL _selector;
    dispatch_source_t _source;
    dispatch_semaphore_t _lock;
}

+ (Yodo1GDCTimer *)timerWithTimeInterval:(NSTimeInterval)interval
                            target:(id)target
                          selector:(SEL)selector
                           repeats:(BOOL)repeats {
    return [[self alloc] initWithFireTime:interval interval:interval target:target selector:selector repeats:repeats];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Yodo1GDCTimer init error" reason:@"Use the designated initializer to init." userInfo:nil];
    return [self initWithFireTime:0 interval:0 target:self selector:@selector(invalidate) repeats:NO];
}

- (instancetype)initWithFireTime:(NSTimeInterval)start
                        interval:(NSTimeInterval)interval
                          target:(id)target
                        selector:(SEL)selector
                         repeats:(BOOL)repeats {
    self = [super init];
    _repeats = repeats;
    _timeInterval = interval;
    _valid = YES;
    _target = target;
    _selector = selector;
    
    __weak typeof(self) _self = self;
    _lock = dispatch_semaphore_create(1);
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_source, dispatch_time(DISPATCH_TIME_NOW, (start * NSEC_PER_SEC)), (interval * NSEC_PER_SEC), 0);
    dispatch_source_set_event_handler(_source, ^{[_self fire];});
    dispatch_resume(_source);
    return self;
}

- (void)invalidate {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_valid) {
        dispatch_source_cancel(_source);
        _source = NULL;
        _target = nil;
        _valid = NO;
    }
    dispatch_semaphore_signal(_lock);
}

- (void)fire {
    if (!_valid) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id target = _target;
    if (!target) {
        dispatch_semaphore_signal(_lock);
        [self invalidate];
    } else {
        dispatch_semaphore_signal(_lock);
        [target performSelector:_selector withObject:self];
        if (!_repeats) {
            [self invalidate];
        }
    }
#pragma clang diagnostic pop
}

- (BOOL)repeats {
    YODO1_LOCK(BOOL repeat = _repeats); return repeat;
}

- (NSTimeInterval)timeInterval {
    YODO1_LOCK(NSTimeInterval t = _timeInterval) return t;
}

- (BOOL)isValid {
    YODO1_LOCK(BOOL valid = _valid) return valid;
}

- (void)dealloc {
    [self invalidate];
}

@end
