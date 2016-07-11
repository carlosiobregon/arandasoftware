//
//  cacheImgs.m
//  arandasoftware
//
//  Created by Carlos Obregón on 11/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import "CacheImgs.h"

@implementation CacheImgs

+(instancetype)sharedInstance {
    static dispatch_once_t onceQueue;
    static CacheImgs *__sharedInstance = nil;
    dispatch_once(&onceQueue, ^{
        __sharedInstance = [[self alloc] init];
    });
    
    return __sharedInstance;
    
}

@end
