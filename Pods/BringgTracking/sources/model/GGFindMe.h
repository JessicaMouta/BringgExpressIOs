//
//  GGFindMe.h
//  BringgTracking
//
//  Created by Matan on 23/06/2016.
//  Copyright © 2016 Matan Poreh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GGFindMeStoreKeyToken @"fmToken"
#define GGFindMeStoreKeyUrl @"fmUrl"
#define GGFindMeStoreKeyEnabled @"fmSupported"

@interface GGFindMe : NSObject<NSCoding>

@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) NSString * _Nullable token;
@property (nonatomic) BOOL enabled;
/**
 *  flag to determine if object data is enough for requesting "find me" from the bringg service for a paritcular order and driver
 */
@property (nonatomic, readonly) BOOL canSendFindMe;




-(nullable instancetype)initWithData:(NSDictionary * _Nullable)data;


- (void)update:(GGFindMe *__nullable)newFindMe;




@end
