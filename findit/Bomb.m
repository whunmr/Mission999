//
//  Bomb.m
//  findit
//
//  Created by Hongmin Wang on 5/13/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Bomb.h"
#import "GameScene.h"
#import "HMHero.h"

static SKAction* bombEmitAction;

@interface Bomb()
@property bool emitted;
@end

@implementation Bomb

static SKAction* emitSound;

+ (void)initialize {
    emitSound = [SKAction playSoundFileNamed:@"fuse.mp3" waitForCompletion:NO];
    bombEmitAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0.5 duration:0.3]
                                           ,[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:0.5 duration:0.3]
                                           ,[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0.8 duration:0.3]
                                           ,[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:0.8 duration:0.3]
                                           ,[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1 duration:0.3]
                                           ,[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:0.3]
                                           ,[SKAction playSoundFileNamed:@"explosion.mp3" waitForCompletion:NO]
                                          ]];
    
}

+(Bomb*)bomb {
    Bomb* bp = [[Bomb alloc] initWithImageNamed:@"bomb.png"];
    bp.name = @"bomb";
    bp.physicsBody.dynamic = NO;
    bp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bp.size];
    bp.physicsBody.categoryBitMask = bomb_category;
    bp.physicsBody.collisionBitMask = 0;
    bp.physicsBody.contactTestBitMask = hero_category;
    bp.physicsBody.fieldBitMask = 0;
    bp.physicsBody.allowsRotation = NO;
    bp.physicsBody.affectedByGravity = NO;
    bp.zPosition = 1;
    
    //SKEmitterNode* star = [SKEmitterNode nodeWithFileNamed:@"monster_fire.sks"];
    bp.xScale = bp.yScale = 0.24;
    //[bp addChild:star];
    return bp;
}

- (void)emit {
    [self runAction:[SKAction sequence:@[
                                         [SKAction group:@[bombEmitAction, emitSound]]
                                         ,[SKAction runBlock:^{
        SKEmitterNode* smokes = [SKEmitterNode nodeWithFileNamed:@"explosion_smokes.sks"];
        smokes.position = self.position;
        [self.parent addChild:smokes];
        
        SKAction* fire_burn_sound = [SKAction repeatAction:[SKAction playSoundFileNamed:@"fire-burning.mp3" waitForCompletion:YES] count:-1];
        SKAction* show_smoks = [SKAction sequence:@[
                                                    [SKAction resizeByWidth:0.01 height:0.01 duration:0.5]
                                                    ,[SKAction _waitForDuration:1]
                                                    ,[SKAction removeFromParent]]];
        [smokes runAction:[SKAction group:@[show_smoks, fire_burn_sound]]];
    }]
                                         
                                         ,[SKAction runBlock:^{
        [self.parent enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
            if ([self intersectsNode:node]) {
                [node removeFromParent];
                //TODO: add smoke
            }
        }];
        
        [self.parent enumerateChildNodesWithName:@"monster" usingBlock:^(SKNode *node, BOOL *stop) {
            CGFloat distance = DistanceBetweenPoints(node.position, self.position);
            if (distance < self.size.width * 2) {
                if ([node conformsToProtocol:@protocol(Hurtable)]) {
                    [((SKNode<Hurtable> *)node) hurtby:nil with:1];
                }
            }
        }];
        
        HMHero* h = [HMHero hero];
        CGFloat distance = DistanceBetweenPoints(h.position, self.position);
        if (distance < self.size.width * 2) {
            [h hurtby:self with:1];
        }
    }]
                                         
    , [SKAction removeFromParent]
    ]]];
}

///////////////////////////////////////////////////////////////////////
-(void)hurtby:(SKSpriteNode*)hurtSource with:(int)hurt {
    if (self.emitted) {
        return;
    }
    
    self.emitted = YES;
    [self emit];
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        [self emit];
        return;
    }
         
    NSLog(@"bomb hit %@", body.node.name);
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}
@end
