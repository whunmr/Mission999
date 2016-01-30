//
//  Key.h
//  findit
//
//  Created by Hongmin Wang on 5/17/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Key : SKSpriteNode<SKContactable>
+(Key*)key_with_flag: (NSString*)fill_flag;

+(BOOL)has_more_key_to_collect;
+(void)reset_keys_count_collected_by_hero;
+(void)set_keys_to_be_collect: (int)keys_count;
+(BOOL)alreay_collected_some_key;
@end
