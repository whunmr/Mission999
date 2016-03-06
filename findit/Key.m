//
//  Key.m
//  findit
//
//  Created by Hongmin Wang on 5/17/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Key.h"
#import "GameScene.h"

@implementation Key

static SKAction* grab_key_sound;

+(void)initialize {
    grab_key_sound = [SKAction playSoundFileNamed:@"grab_key.mp3" waitForCompletion:NO];
}

+(Key*)key_with_flag: (NSString*)fill_flag {
    Key* k = [[Key alloc] initWithImageNamed:@"key.png"];
    k.name = @"key";
    
    k.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:k.size];
    k.physicsBody.allowsRotation = NO;
    k.physicsBody.dynamic = NO;
    if ([fill_flag isEqualToString:@"#007fff"]) {
        k.physicsBody.dynamic = YES;
    }

    k.physicsBody.categoryBitMask = key_category;
    k.physicsBody.collisionBitMask = key_category | ground_category;
    k.physicsBody.contactTestBitMask = hero_category;
    k.physicsBody.fieldBitMask = 0;
    k.xScale = k.yScale = 0.2;
    
    k.blendMode = SKBlendModeAdd;
    
    SKEmitterNode* magic_effect = [SKEmitterNode nodeWithFileNamed:@"magic_ball.sks"];
    magic_effect.zPosition = k.zPosition-1;
    [k addChild:magic_effect];
    
    //[k runAction:[SKAction colorizeWithColor:[SKColor randomColor] colorBlendFactor:0.8 duration:0]];
    return k;
}

static int keys_collected =  0;
static int keys_count_to_collect_ = 0;

+(BOOL)alreay_collected_some_key {
    return keys_count_to_collect_==0 || keys_collected > 0;
}

+(BOOL)has_more_key_to_collect {
    return keys_count_to_collect_ > 0;
}

+(void)reset_keys_count_collected_by_hero {
    keys_count_to_collect_ = 0;
}

+(void)set_keys_to_be_collect: (int)keys_count {
    [[GameScene sharedInstance] update_hero_bullet_count_to: [NSString stringWithFormat:@"0/%d", keys_count]];
    keys_count_to_collect_ = keys_count;
    keys_collected = 0;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {        
        keys_count_to_collect_--;
        keys_collected++;
        
        [[GameScene sharedInstance] update_hero_bullet_count_to: [NSString stringWithFormat:@"%d", keys_collected]];
        
        [self runAction: [SKAction sequence:@[grab_key_sound, [SKAction removeFromParent]]]];
        return;
    }

    NSLog(@"key hit %@", body.node.name);
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
