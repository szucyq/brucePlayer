//
//  Singleton.m
//  iCity
//
//  Created by zhou ly on 12-4-9.
//  Copyright (c) 2012年 http://www.sznews.com. All rights reserved.
//

#import "Singleton.h"

static  Singleton *instance = nil;

@implementation Singleton
@synthesize cacheDoc;

+ (Singleton *)sharedInstance{
    //synchronized   这个主要是考虑多线程的程序，这个指令可以将{ } 内的代码限制在一个线程执行，如果某个线程没有执行完，其他的线程如果需要执行就得等着。
    //@synchronized(self) ： 这个就是同步语义，这里会自动加锁，以保证多线程的环境，不会new出多个实例来。[[self alloc] 会默认调用 [self allocWithZone] 所以在sharedInstance里没有将值给 instance
    @synchronized(self)
    {
        if (instance == nil)
        {            
            instance = [[self alloc] init];
        }
    }
    return instance;
}

//allocWithZone 这个是重载的，因为这个是从指定的内存区域读取信息创建实例，所以如果需要的单例已经有了，就需要禁止修改当前单例。所以返回 nil
+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (instance == nil){
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}
- (id)autorelease
{
    return self;
}

- (void)dealloc{
    [cacheDoc release];
    [super dealloc];
}
@end
