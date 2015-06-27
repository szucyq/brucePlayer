//
//  Singleton.h
//  iCity
//
//  Created by zhou ly on 12-4-9.
//  Copyright (c) 2012年 http://www.sznews.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject{
    NSString      *cacheDoc;
}
@property (nonatomic,copy)NSString *cacheDoc;

+ (Singleton *)sharedInstance;
@end
