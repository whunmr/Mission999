//
//  HMHero.h
//  findit
//
//  Created by Hongmin Wang on 1/3/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface HMHero : SKSpriteNode<SKContactable, Hurtable>
+(HMHero*)hero;
+(HMHero*)new_hero;

-(CGVector)velocity;

-(void)reset_status;

-(void)jump;
-(void)jump_end_on_ground: (SKSpriteNode*)ground;

-(void)fire;
-(void)hurtby:(SKSpriteNode*)hurtSource with:(int)hurt;

-(void)begin_move_left;
-(void)begin_move_right;

-(void)end_move_left;
-(void)end_move_right;

-(void)update:(CFTimeInterval)interval current:(CFTimeInterval)currentTime;

-(void)add_bullet:(int)count;
@property int bullet_count;

-(void)addShield:(SKSpriteNode*)shield;

@end
