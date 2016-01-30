//
//  LevelEntry.m
//  findit
//
//  Created by Hongmin Wang on 5/5/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "LevelEntry.h"
#import "GameScene.h"
#import "HMHero.h"
#import "Key.h"


@interface LevelEntry()
@property NSString* levelName;
@end

@implementation LevelEntry
@synthesize levelName;

+(LevelEntry*)levelEntry:(NSString*)level {
    //LevelEntry* le = [LevelEntry spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(30, 30)];
    LevelEntry* le = [LevelEntry spriteNodeWithImageNamed:@"level_entry.png"];
    le.size = CGSizeMake(30, 30);
    le.anchorPoint = CGPointMake(0.5, 0.2);
    
    le.levelName = level;
    
    le.name = @"final";
    le.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:le.size];
    le.physicsBody.categoryBitMask = game_final_category;
    le.physicsBody.collisionBitMask = hero_category | game_final_category | ground_category;
    le.physicsBody.contactTestBitMask = hero_category;
    le.physicsBody.fieldBitMask = 0;
    le.physicsBody.dynamic = NO;
    
    SKLabelNode* level_label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE"];
    level_label.name = @"bullet_count";
    level_label.color = [SKColor redColor];
    level_label.fontColor = [SKColor yellowColor];
    level_label.colorBlendFactor = 0.5f;
    level_label.blendMode = SKBlendModeReplace;
    level_label.fontSize = 18;
    level_label.text = level;
    level_label.position = CGPointZero;
    level_label.zPosition = le.zPosition+1;
    
    [le addChild:level_label];
    
    return le;
}

///////////////////////////////////////////////////////////////////////
- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        
        if ( ! [Key has_more_key_to_collect]) {
        //if ([Key alreay_collected_some_key]) {
            [self removeFromParent];
            
            HMHero* h = [HMHero hero];
            
            [h runAction:[SKAction sequence:@[
                                              [SKAction runBlock:^{ [h hurtby:self with:-1]; }],
                                              [SKAction _waitForDuration:0.1],
                                              [SKAction runBlock:^{ [h hurtby:self with:-1]; }],
                                              [SKAction _waitForDuration:0.1],
                                              [SKAction runBlock:^{ [h hurtby:self with:-1]; }],
                                              [SKAction _waitForDuration:0.1],
                                              [SKAction runBlock:^{
                                                [[GameScene sharedInstance] before_enter_new_level:self.position];
                                              }],
                                              
                                              [SKAction waitForDuration:0.2],
                                              
                                              [SKAction runBlock:^{
                                                    [[GameScene sharedInstance] restart_to_level:[NSString stringWithFormat:@"level%@", levelName]];
                                              }]
                                              
                                              ]]];

        } else {
            //TODO: play visual or sound to notify need more keys to open door to next level.
        }
        
        return;
    }
    
    NSLog(@"Level entry hit %@", body.node.name);
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
