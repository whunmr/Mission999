//
//  HMHero.m
//  findit
//
//  Created by Hongmin Wang on 1/3/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "HMHero.h"
#import "common.h"
#import "Bullet.h"
#import "GameScene.h"
#import "Ground.h"

@interface HMHero ()
@property int horizental_move_direction;
@property int direction;
@property int jump_count;
@property CGVector velocity_of_last_frame;
@property SKEmitterNode* jump_sparks;
@property SKSpriteNode* left_eye;
@property SKSpriteNode* right_eye;
@property int health;
@property SKSpriteNode* shield__;
@end

@implementation HMHero
@synthesize bullet_count;

static SKTexture* hero_left_texture;
static SKTexture* hero_right_texture;

static SKAction* actionJumpSound;
static SKAction* actionNoMoreBulletSound;
static SKAction* actionGunShotSound;
static SKAction* actionJumpLeft;
static SKAction* actionJumpRight;

static SKAction* actionHurtSound;
static SKAction* actionHealSound;
//static SKAction* onHurtPulseRed;
//static SKEmitterNode* HurtEffect;
//static SKEmitterNode* HealEffect;


static SKAction* actionShieldSound;
static BOOL isGameOver;

static HMHero* h;

+ (void) initialize {
    isGameOver = NO;
    //if (self == [MyParentClass class]) {
    //    // Once-only initializion
    //}
    // Initialization for this class and any subclasses
    actionJumpSound = [SKAction playSoundFileNamed:@"jump3.mp3" waitForCompletion:NO];
    actionNoMoreBulletSound = [SKAction playSoundFileNamed:@"no_more_bullet.mp3" waitForCompletion:NO];
    actionGunShotSound = [SKAction playSoundFileNamed:@"gun_fire.mp3" waitForCompletion:NO];
//    actionHurtSound = [SKAction playSoundFileNamed:@"hurt_sound.wav" waitForCompletion:NO];
    actionHurtSound = [SKAction playSoundFileNamed:@"sound/hurt.mp3" waitForCompletion:NO];
//    actionHealSound = [SKAction playSoundFileNamed:@"healing.mp3" waitForCompletion:NO];
    actionHealSound = [SKAction playSoundFileNamed:@"sound/add_health.mp3" waitForCompletion:NO];
    actionShieldSound = [SKAction playSoundFileNamed:@"shield.mp3" waitForCompletion:NO];
    
    actionJumpLeft = [SKAction group:@[actionJumpSound,
                                       [SKAction sequence:@[
                                                            [SKAction _waitForDuration:0.005], [SKAction rotateByAngle:M_PI*-2 duration:0.15]
                                                            ]
                                        ]
                                       ]];
    
    actionJumpRight = [SKAction group:@[actionJumpSound,
                                        [SKAction sequence:@[
                                                             [SKAction _waitForDuration:0.005], [SKAction rotateByAngle:M_PI*2 duration:0.15]
                                                             ]
                                         ]
                                        ]];
    

//    HurtEffect = [SKEmitterNode nodeWithFileNamed:@"after_hurt.sks"];
//    HurtEffect.name = @"HurtEffect";
//    HurtEffect.zPosition = 2000;
//    
//    HealEffect = [SKEmitterNode nodeWithFileNamed:@"after_heal.sks"];
//    HealEffect.name = @"HealEffect";
//    HealEffect.zPosition = 2000;
    
    
    //hero_left_texture = [SKTexture textureWithImageNamed:@"hero_left.png"];
    //hero_right_texture = [SKTexture textureWithImageNamed:@"hero_right.png"];
}

+(HMHero*)hero {
    return h;
}

+(HMHero*)new_hero {
    h = [[HMHero alloc] initWithColor:[SKColor colorWithHexString:@"#CCFF00" alpha:1.0]
                                         size:CGSizeMake(10, 10)];
    
    //h.texture = [SKTexture textureWithImageNamed:@"hero.jpg"];
    //h.xScale = h.yScale = 0.08;
    
    /*SKSpriteNode* heart = [[SKSpriteNode alloc] initWithImageNamed:@"heart1.jpg"];
    heart.xScale = heart.yScale = 0.08;
    heart.position = CGPointMake(20, 20);
    [h addChild:heart];*/
    
    [h reset_status];
    
    h.name = @"hero";
    h.horizental_move_direction = 0;
    h.direction = 1;
    h.texture = hero_right_texture;
    h.velocity_of_last_frame = CGVectorMake(0, 0);
    
    h.left_eye = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(2.5, 2.5)];
    h.right_eye = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(2.5, 2.5)];

    h.left_eye.position = CGPointMake(-2, 2.5);
    h.right_eye.position = CGPointMake(3, 2.5);
    h.zPosition = k_hero_zposition;
    
    [h addChild:h.left_eye];
    [h addChild:h.right_eye];
    
    h.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:h.size];
    h.physicsBody.allowsRotation = YES;
    h.physicsBody.restitution = 0.0;
    h.physicsBody.dynamic = YES;
    h.physicsBody.categoryBitMask = hero_category;
    h.physicsBody.collisionBitMask = hero_category | ground_category | monster_category
                                     | game_final_category | star_category | spikes_category;
    
    h.physicsBody.contactTestBitMask = hero_category | ground_category | monster_category
                                     | game_final_category | star_category;
    h.physicsBody.fieldBitMask = 0;
    h.physicsBody.friction = 1.0;
    
    return h;
}

-(void)reset_status {
    isGameOver = NO;
    h.bullet_count = 10;
    h.jump_count = 0;
    h.health = 1;
    h.horizental_move_direction = 0;
    
    h.physicsBody.velocity = CGVectorMake(0, 0);
    h.physicsBody.angularVelocity = 0;
    
    [[GameScene sharedInstance] update_hero_bullet_count_to:@"0/0"];
    [[GameScene sharedInstance] update_hero_health_to:h.health];
    
    [self remove_shield];
}

static uint32_t retry_jump_count = 1;

-(void)jump {
    bool continousJumpEnable = [self.physicsBody.joints count] <= 0;
    
    if (continousJumpEnable && self.jump_count >= 2 && retry_jump_count++ % 20 != 0) {
        return;
    }
    
    retry_jump_count = 1;
    self.jump_count++;
    self.physicsBody.velocity = CGVectorMake(self.physicsBody.velocity.dx, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0, 1.2 * (self.parent.scene.physicsWorld.gravity.dy > 0 ? -1 : 1) )];
    [self runAction:actionJumpSound];
    
    //+ (SKAction *)colorizeWithColor:(SKColor *)color colorBlendFactor:(CGFloat)colorBlendFactor duration:(NSTimeInterval)sec;
    //+ (SKAction *)colorizeWithColorBlendFactor:(CGFloat)colorBlendFactor duration:(NSTimeInterval)sec;

    /*if (self.jump_count == 2) {
        if (self.direction == 1) {
            [self runAction:actionJumpLeft];
        } else {
            [self runAction:actionJumpRight];
        }
    }*/
}


-(CGVector)velocity {
    return self.physicsBody.velocity;
}

-(void)jump_end_on_ground: (SKSpriteNode*)ground {
    if (ground != nil) {
        //push hero out of ground edge, to make the hero can not climb up by little gay between stones.
//        if (self.parent.scene.physicsWorld.gravity.dy < 0) {
//        if (/*BOOL onLeftEdgeOfGround =*/ self.position.x < ground.position.x - ground.size.width/2) {
//            SKNode* aboveNode = [self.parent nodeAtPoint:CGPointMake(self.position.x + self.size.width/2 + 3, self.position.y + self.size.height/2 + 3)];
//            if ([aboveNode.name isEqualToString:@"ground"]) {
//                    //[self.physicsBody applyImpulse:CGVectorMake(-0.26, -0.05)];
//                //[self runAction:[SKAction moveByX:-self.size.width y:-2 duration:0.01]];
//                return;
//            }
//        } else if (/*BOOL onRightEdgeOfGround= */ self.position.x > ground.position.x + ground.size.width/2) {
//            SKNode* aboveNode = [self.parent nodeAtPoint:CGPointMake(self.position.x -self.size.width/2 - 3, self.position.y + self.size.height/2 + 3)];
//            if ([aboveNode.name isEqualToString:@"ground"]) {
//                //[self.physicsBody applyImpulse:CGVectorMake(0.26, -0.05)];
//                //[self runAction:[SKAction moveByX:self.size.width y:-2 duration:0.01]];
//                return;
//            }
//        }
//        }
    }
    

    self.jump_count = 0;
    retry_jump_count = 1;

    //if (self.physicsBody.velocity.dy > 40) {
    //    [self runAction:actionFoodStepOnGroundSound];
    //}
    
    self.physicsBody.velocity = CGVectorMake(0, 0);
    
    if (self.zRotation != 0) {
        [self runAction:[SKAction rotateToAngle:0 duration:0.1]];
    }
}


-(void)add_bullet:(int)count {
    self.bullet_count = MIN(self.bullet_count + 10, 60);
    //[[GameScene sharedInstance] update_hero_bullet_count_to:self.bullet_count];
}

-(void)fire {
    if (self.bullet_count <= 0) {
        [self runAction:actionNoMoreBulletSound];
        return;
    }
    
    CGPoint initPos = CGPointMake(self.position.x + 5.0, self.position.y);
    Bullet* bullet = [Bullet bullet];
    bullet.position = initPos;
    [self.parent addChild:bullet];
    
    SKAction* bulletAction = [SKAction sequence:
                              @[[SKAction moveTo:CGPointMake(initPos.x + self.direction * 3000, initPos.y) duration:10],
                                [SKAction removeFromParent]]];
    
    [bullet runAction:[SKAction group:@[bulletAction, actionGunShotSound]]];
    if (self.bullet_count > 0)
        self.bullet_count--;
    
    //[[GameScene sharedInstance] update_hero_bullet_count_to:self.bullet_count];
}

static int hurt_delay_counter = 0;
-(void)hurtby:(SKSpriteNode*)hurtSource with:(int)hurt {
    if (isGameOver) {
        return;
    }
    
    if (hurt_delay_counter > 0) {
        return;
    }
    hurt_delay_counter = 10;
    
    if (hurt > 0 && self.shield__ != nil) {
        [self remove_shield];
        [self runAction:actionShieldSound];
        return;
    }
    
    //TODO: if health value of hero down to 0, then game over.
    //NSLog(@"hurt by %@", hurtSource);
    
    self.health = self.health - hurt;
    self.health = MIN(self.health, 10);
    
    [[GameScene sharedInstance] update_hero_health_to:h.health];
    
    if (self.health <= 0) {
        isGameOver = YES;
        
        [self runAction:[SKAction sequence:@[
                                             [SKAction _waitForDuration:0.3],
                                             [SKAction runBlock:^{
                                                  [[GameScene sharedInstance] game_over];
                                            }]
                                    ]]];
    }
    
    if (hurt > 0) {
        [self runAction: actionHurtSound];
        
        SKEmitterNode* HurtEffect = [SKEmitterNode nodeWithFileNamed:@"after_hurt.sks"];
        HurtEffect.name = @"HurtEffect";
        HurtEffect.zPosition = 2000;

        [self addChild:HurtEffect];
        [self runAction:
         [SKAction sequence:@[
                              [SKAction _waitForDuration:0.5],
                              [SKAction runBlock:^{
                                    [HurtEffect removeFromParent];
                              }]
                            ]]
         ];

    } else if (hurt < 0) {
        
        [self runAction: actionHealSound];
        SKEmitterNode* HealEffect = [SKEmitterNode nodeWithFileNamed:@"after_heal.sks"];
        HealEffect.name = @"HealEffect";
        HealEffect.zPosition = 2000;

        [self addChild:HealEffect];
        [self runAction:
         [SKAction sequence:@[
                              [SKAction _waitForDuration:0.5],
                              [SKAction runBlock:^{
                                   [HealEffect removeFromParent];
                               }]
                            ]]
         ];
    }
}

-(void)begin_move_left {
    self.horizental_move_direction = -1;
    self.direction = -1;
    self.left_eye.color = [SKColor redColor];
    self.right_eye.color = [SKColor blackColor];
    //h.texture = hero_left_texture;
}

-(void)begin_move_right {
    self.horizental_move_direction = 1;
    self.direction = 1;
    self.left_eye.color = [SKColor blackColor];
    self.right_eye.color = [SKColor redColor];
    //h.texture = hero_right_texture;
}

-(void)end_move_left {
    self.horizental_move_direction = 0;
}

-(void)end_move_right {
    self.horizental_move_direction = 0;
}


//static CFTimeInterval lastLazyUpdateTime = 0;

-(void)update:(CFTimeInterval)interval current:(CFTimeInterval)currentTime {
    --hurt_delay_counter;
    
    if (self.horizental_move_direction != 0) {
        //NSLog(@"-----:  %d", self.horizental_move_direction);
        SKAction* move = [SKAction moveByX:self.horizental_move_direction * 2 y:0 duration:0.001];
        
        NSArray<SKPhysicsJoint*>* joints = self.physicsBody.joints;
        if ([joints count] > 0) {
            for (SKPhysicsJoint* joint in joints) {
                [joint.bodyA.node runAction:move];
                [joint.bodyB.node runAction:move];
            }
        } else {
            [self runAction:move];
        }
    }

    if (self.physicsBody.velocity.dy == self.velocity_of_last_frame.dy) {
        self.jump_count = 0;
    } else {
        self.velocity_of_last_frame = self.physicsBody.velocity;
    }
    
    /*if (currentTime - lastLazyUpdateTime > 0.3) {
        lastLazyUpdateTime = currentTime;
        

        [self.parent enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
                Ground* g = (Ground*)node;
            if (g.isHidden) {
                
                CGFloat border = 60;
                CGRect blockVisibleRect = CGRectMake(g.position.x - g.size.width/2 - border, g.position.y - g.size.height/2 - border
                                                     , g.size.width + border * 2, g.size.height + border * 2);
                
                if (CGRectContainsPoint(blockVisibleRect, self.position)) {
                    [g runAction:[SKAction fadeInWithDuration:0.5]];
                } else {
                    [g runAction:[SKAction fadeAlphaTo:0.1 duration:1]];
                }
            }
        }];
    }*/
}


////////////////////////////////////////////////////////////////////////////////
- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
        return;
    }
    
    NSLog(@"hero hit %@", body.node.name);
}


-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) end_contact:self.physicsBody with:contact];
        return;
    }
}


////////////////////////////////////////////////////////////////////////////////
-(void)addShield:(SKSpriteNode*)shield {
    [self remove_shield];
    
    [shield removeFromParent];
    shield.physicsBody = nil;
    
    shield.position = CGPointMake(self.size.width/2, self.size.height/2);
    
    
    [self addChild:shield];
    
    self.shield__ = shield;
    [self runAction:actionShieldSound];
}

- (void)remove_shield {
    if (h.shield__ != nil) {
        [h.shield__ removeFromParent];
        h.shield__ = nil;
    }
}


@end
