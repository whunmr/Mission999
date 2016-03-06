//
//  Ground.m
//  findit
//
//  Created by Hongmin Wang on 5/3/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Ground.h"
#import "HMHero.h"
#import "Spike.h"

@interface Ground()
//@property BOOL isGlass;
//@property BOOL isSand;
//@property BOOL isHidden;
@property int glass_block_id;
@end

@implementation Ground
static int global_glass_block_id;

static SKAction* actionFoodStepOnGroundSound;
static SKAction* actionFoodStepOnGlassSound;
static SKAction* actionFoodStepOnSandSound;
static SKAction* actionSandFallingSound;
static SKTexture* wall_texture;

static SKTexture* customized_wall_texture;
static SKTexture* sand_ground_texture;
static SKTexture* default_ground_texture;
static SKTexture* hidden_ground_texture;
static SKTexture* transparent_wall_texture;
static SKTexture* static_spikes_texture;
static SKTexture* bombable_texture;
static SKTexture* woodwall_texture;
static NSMutableArray* glass_contact_sounds;

+ (void) initialize {
    glass_contact_sounds = [NSMutableArray new];
    for (int i = 1; i < 13; ++i) {
        [glass_contact_sounds addObject:[SKAction playSoundFileNamed: [NSString stringWithFormat:@"g%d.mp3", i] waitForCompletion:NO]];
    }
    
    sand_ground_texture = [SKTexture textureWithImageNamed:@"sand.png"];
    default_ground_texture = [SKTexture textureWithImageNamed:@"wallxxx.jpg"];
    hidden_ground_texture = [SKTexture textureWithImageNamed:@"egypt_chars.jpg"];
    customized_wall_texture = [SKTexture textureWithImageNamed:@"dynamic_walls0.jpg"];
    transparent_wall_texture = [SKTexture textureWithImageNamed:@"bokeh4.jpg"];
    static_spikes_texture = [SKTexture textureWithImageNamed:@"static_spikes.png"];
    actionFoodStepOnGroundSound = [SKAction playSoundFileNamed:@"footstep-on-stone.mp3" waitForCompletion:NO];
    actionFoodStepOnGlassSound = [SKAction playSoundFileNamed:@"land_on_glass.mp3" waitForCompletion:NO];
    actionFoodStepOnSandSound = [SKAction playSoundFileNamed:@"step_on_sand.mp3" waitForCompletion:NO];
    actionSandFallingSound = [SKAction playSoundFileNamed:@"sand_falling.mp3" waitForCompletion:NO];
    bombable_texture = [SKTexture textureWithImageNamed:@"diamonds.jpg"];
    woodwall_texture = [SKTexture textureWithImageNamed:@"woodwall.jpg"];
}

+(Ground*)newGroundBlock:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h r:(CGFloat)r c:(SKColor*)c fill_flag:(NSString*)fill_flag{
    
    Ground* ground;
    if ([fill_flag isEqualToString:@"#000000"]) {
        ground = [[Ground alloc] initWithColor:c size:CGSizeMake(w, 10)];
    } else {
        ground = [[Ground alloc] initWithColor:c size:CGSizeMake(w, h)];
    }
    
    //ground.blendMode = SKBlendModeReplace;

    /*int xxx = arc4random_uniform(wall_texture.size.width - w);
    int yyy = arc4random_uniform(wall_texture.size.height - h);
    CGFloat wallwidth = wall_texture.size.width;
    CGFloat wallheight = wall_texture.size.height;
    ground.texture = [SKTexture textureWithRect:CGRectMake( xxx/wallwidth, yyy/wallheight, w/wallwidth, h/wallheight) inTexture:wall_texture];
    */
    
    //ground.colorBlendFactor = 0.8;
    ground.name = @"ground";
    ground.position = CGPointMake(x, y);
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size];
    ground.physicsBody.dynamic = NO;
    
    ground.physicsBody.friction = 0;
    ground.physicsBody.categoryBitMask = ground_category;
    ground.physicsBody.collisionBitMask = hero_category | star_category | ground_category;
    ground.physicsBody.contactTestBitMask = 0;
    ground.physicsBody.fieldBitMask = 0;
    
    
    if ( ! [fill_flag isEqualToString:@"#fff"] &&  ! [fill_flag isEqualToString:@"none"]) {
        if ([fill_flag isEqualToString:@"#ff0000"]) {
            ground.isStepDownable = YES;
            [ground apply_random_special_texture_to_moveable_block:hidden_ground_texture];
        } else if ([fill_flag isEqualToString:@"#ffff00"]) {
            [ground set_as_sand_block];
        } else if ([fill_flag isEqualToString:@"#00ff00"]) {
            ground.isSpikeAround = YES;
        } else if ([fill_flag isEqualToString:@"#ff7f00"]) {
            ground.isSticky = YES;
        } else if ([fill_flag isEqualToString:@"#000000"]) {
            ground.isStaticSpikes = YES;
            SKTexture* t = [SKTexture textureWithRect:CGRectMake(0, 0
                                                                 , ground.size.width / static_spikes_texture.size.width
                                                                 , 0.97)
                                            inTexture:static_spikes_texture];
            ground.texture = t;
            ground.zPosition = ground.zPosition - 1;
        } else if ([fill_flag isEqualToString:@"#007fff"]) {
            ground.isDynamicBlock = YES;
            ground.physicsBody.dynamic = YES;
            [ground apply_random_special_texture_to_moveable_block:woodwall_texture];
        }
    }
    /*{
        [ground runAction:[SKAction colorizeWithColor:c colorBlendFactor:0.9 duration:0]];
    }*/
    
    ground.zRotation = - D_2_R(r);
    return ground;
}

-(void)final_colorize {
    BOOL hasSpecialTexture = self.isGlass || self.isSand || self.isStepDownable || self.isSticky || self.isStaticSpikes || self.isBombable || self.isDynamicBlock ;
    
    if ( ! hasSpecialTexture){
        //[self apply_random_special_texture_to_moveable_block:default_ground_texture];
        //[self runAction:[SKAction colorizeWithColor:[SKColor randomColor] colorBlendFactor:0.1 duration:0]];
    }
    
    if (self.isSpikeAround) {
        Spike* s = [Spike spike:@"s"];
        s.xScale = s.yScale = s.xScale * 0.8;
        s.position = CGPointMake(self.position.x - self.size.width/2 - 14, self.position.y - self.size.height/2 - 14);
        CGMutablePathRef rect = CGPathCreateMutable();
        CGPathAddRect(rect, nil, CGRectMake(self.position.x - self.size.width/2 - 14
                                            , self.position.y - self.size.height/2 -14
                                            , self.size.width + 28
                                            , self.size.height + 28));
        CGPathCloseSubpath(rect);

        [self.parent addChild:s];
        
        int delay = arc4random_uniform(10);
        int duration = MAX(4,  8 * (arc4random_uniform(100) + 1)/100);
        
        [s runAction:
            [SKAction sequence:@[
                                 [SKAction _waitForDuration:delay],
            [SKAction repeatActionForever:
                [SKAction group:@[
                   [SKAction followPath:rect asOffset:NO orientToPath:NO duration:duration]
                   , [SKAction rotateByAngle:-M_PI duration:2]
                ]]
            ]
            ]]
        ];
        

    }
}


////////////////////////////////////////////////////////////////////////////////
- (void)hit_hero:(HMHero*)h {
    if (h.velocity.dy > 40) {
        [self runAction:actionFoodStepOnGroundSound];
    }
    [h jump_end_on_ground: self];
}

-(void)apply_sand_block_destory_actions {
    if (![self hasActions]) {
    SKEmitterNode* e = (SKEmitterNode*)[self childNodeWithName:@"sand_effect"];
    e.particleBirthRate *= 2;
    e.particleSpeed *= 1.5;
    
    [self runAction:[SKAction sequence:@[
                                            actionFoodStepOnSandSound,
                                            
                                            [SKAction group:@[
                                                              actionSandFallingSound,
                                                              [SKAction sequence:@[
                                                                                   [SKAction fadeOutWithDuration:1],
                                                                                   [SKAction removeFromParent]
                                                              ]]
                                            ]]
                                         ]]];
    }
}

static int global_glass_contact_sound_id = 0;

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"balloon"]) {
        if (self.isStaticSpikes) {
             [(SKSpriteNode<Hurtable>*)body.node hurtby:self with:1];
        }
        return;
    }
    
    if ([body.node.name isEqualToString:@"hero"]) {
        HMHero* h = [HMHero hero];
        
        if (self.isSticky) {
            //play sticky sound
            [h jump_end_on_ground:nil];
            [h.physicsBody applyImpulse:CGVectorMake(0, 1)];
            return;
        }
        
        if (self.isSand) {
            [self apply_sand_block_destory_actions];
        }
        
        CGFloat gravityDY = self.parent.scene.physicsWorld.gravity.dy;
        
            
        if (
                (gravityDY < 0  &&    (       ([contact.bodyA.node.name isEqualToString:@"hero"] && contact.contactNormal.dy < -0.001)
                                          ||  ([contact.bodyB.node.name isEqualToString:@"hero"] && contact.contactNormal.dy > 0.001)
                                      )
                 )
            
                ||
                (gravityDY > 0 &&    (       ([contact.bodyA.node.name isEqualToString:@"hero"] && contact.contactNormal.dy > 0.99)
                                          || ([contact.bodyB.node.name isEqualToString:@"hero"] && contact.contactNormal.dy < -0.99)
                                     )
                )
           )
        {
                //return [self hit_hero:h];
                if (fabs(h.velocity.dy) > 40) {
                    if (! self.isGlass) {
                        [self runAction:actionFoodStepOnGroundSound];
                    }
                }
            
               [h jump_end_on_ground: self];
        }
        
        
        if (self.isStaticSpikes) {
            [h hurtby:self with:1];
        }
        
        if (self.isGlass) {
            static CFTimeInterval startTime;
            CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
            
            if (elapsedTime > 0.2) {
                startTime = CACurrentMediaTime();
                //[self runAction:[SKAction playSoundFileNamed: [NSString stringWithFormat:@"g%d.mp3", self.glass_block_id % 12 + 1] waitForCompletion:NO]];
                //[self runAction:[SKAction playSoundFileNamed: [NSString stringWithFormat:@"g%d.mp3", global_glass_contact_sound_id++ % 12 + 1] waitForCompletion:NO]];
                int index = global_glass_contact_sound_id++ % 12;
                [self runAction:[glass_contact_sounds objectAtIndex:index]];
            }
            //[self runAction:actionFoodStepOnGlassSound];
            //if (h.velocity.dy > 10)
        }
        
        if (self.isStepDownable) {
            [self runAction:
             [SKAction sequence:@[
                                  [SKAction _waitForDuration:1],
                                  [SKAction runBlock:^{
                 self.physicsBody.dynamic = YES;
                 self.physicsBody.affectedByGravity = YES;
             }],
                                  [SKAction _waitForDuration:5],
                                  [SKAction removeFromParent]
                                  ]]
             ];
            return;
        }
        
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
    } else {
        NSLog(@"ground hit %@", body.node.name);
    }
}


-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}



-(void)apply_random_special_texture_to_moveable_block:(SKTexture*)customized_wall_texture {
    int xxx = arc4random_uniform(customized_wall_texture.size.width - self.size.width);
    int yyy = arc4random_uniform(customized_wall_texture.size.height - self.size.height);
    CGFloat wallwidth = customized_wall_texture.size.width-2;
    CGFloat wallheight = customized_wall_texture.size.height-2;
    SKTexture* t = [SKTexture textureWithRect:CGRectMake( xxx/wallwidth, yyy/wallheight, self.size.width/wallwidth, self.size.height/wallheight)
                                    inTexture:customized_wall_texture];
    
    self.texture = t;
}

-(void)set_as_moveable_block:(NSString*)param {
    self.isGlass = YES;
    self.physicsBody.friction = 1;

    //NSLog(@"-------------------> got parameter: %@", param);
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    if ([ps count] >= 4) {
        //CGFloat tag = [[ps objectAtIndex:0] doubleValue];
        
        CGFloat x_move = [[ps objectAtIndex:1] doubleValue];
        CGFloat y_move = [[ps objectAtIndex:2] doubleValue];
        CGFloat move_duration = [[ps objectAtIndex:3] doubleValue];
        
        CGFloat initalWaitDuration = ValueOfIndexInTextArray(ps, 4);
        CGFloat waitBeforeMoveForward = ValueOfIndexInTextArray(ps, 5);
        CGFloat waitBeforeMoveBackward = ValueOfIndexInTextArray(ps, 6);
        
        
        //NSLog(@"x/y/move_duration: %f/%f/%f", x_move, y_move, move_duration);
        if (!self.isStaticSpikes) {
            [self apply_random_special_texture_to_moveable_block: customized_wall_texture];
        }
        
        [self runAction:
            [SKAction sequence:@[
               [SKAction _waitForDuration:initalWaitDuration],
               [SKAction repeatActionForever:
                    [SKAction sequence:@[
                        [SKAction _waitForDuration:waitBeforeMoveForward],
                        [SKAction EaseInOutMoveByX:x_move y:y_move duration:move_duration],
                        [SKAction _waitForDuration:waitBeforeMoveBackward],
                        [SKAction EaseInOutMoveByX:-x_move y:-y_move duration:move_duration]
                        ]]]
            ]]
         ];
    }
}

-(void)set_as_visible_block:(NSString*)param {
    self.isGlass = YES;
    self.glass_block_id = global_glass_block_id++;
    
    SKPhysicsBody* phyBody = self.physicsBody;
//    static uint32_t collisionBitMask_ = self.physicsBody.collisionBitMask;
//    static uint32_t contactTestBitMask_ = self.physicsBody.contactTestBitMask;
    
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    if ([ps count] >= 3) {
        CGFloat wait_duration = [[ps objectAtIndex:0] doubleValue];
        CGFloat fade_out_duration = [[ps objectAtIndex:1] doubleValue];
        CGFloat fade_out_wait = [[ps objectAtIndex:2] doubleValue];
        CGFloat initalWaitDuration = 0;
        if ([ps count] >=4 ) {
            initalWaitDuration = [[ps objectAtIndex:3] doubleValue];
        }
        
        //NSLog(@"x/y/move_duration: %f/%f/%f", x_move, y_move, move_duration);
        //self.color = [SKColor redColor];
        [self apply_random_special_texture_to_moveable_block: transparent_wall_texture];
        //self.blendMode = SKBlendModeAdd;
        
    [self runAction:
       [SKAction sequence:@[
         [SKAction _waitForDuration:initalWaitDuration],
         [SKAction repeatActionForever:
          [SKAction sequence:@[
                               [SKAction _waitForDuration:wait_duration],
                               [SKAction fadeAlphaTo:0 duration:fade_out_duration],
                               [SKAction runBlock:^{
                                    self.physicsBody = nil;
                                }],
                               [SKAction _waitForDuration:fade_out_wait],
                               
                               [SKAction runBlock:^{
                                    self.physicsBody = phyBody;
                                }],
                               //play sound
                               [SKAction fadeAlphaTo:1 duration:fade_out_duration]
                               //,[SKAction colorizeWithColor:[SKColor randomColor] colorBlendFactor:1 duration:0.01]
                              ]]]
         ]]
         ];
    }
}

-(void)set_as_scale_block:(NSString*)param {
    self.isGlass = YES;
    self.glass_block_id = global_glass_block_id++;
    
    //self.anchorPoint = CGPointMake(0, 0);
    //self.position = CGPointMake(self.position.x - self.size.width/2, self.position.y - self.size.height/2);
    self.texture = nil;
    self.color = [SKColor randomColor];
    
    CGFloat originalWidth = self.size.width;
    CGFloat originalHeight = self.size.height;
    
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    if ([ps count] >= 3) {
        CGFloat loop_wait = ValueOfIndexInTextArray(ps, 0);
        CGFloat toX = ValueOfIndexInTextArray(ps, 1);
        CGFloat toY = ValueOfIndexInTextArray(ps, 2);
        
        CGFloat xDirection = ValueOfIndexInTextArray(ps, 3);
        CGFloat yDirection = ValueOfIndexInTextArray(ps, 4);
        
        CGFloat scale_duration = ValueOfIndexInTextArray(ps, 5);
        CGFloat scale_wait =  ValueOfIndexInTextArray(ps, 6);
        
        CGFloat initalWaitDuration = ValueOfIndexInTextArray(ps, 7);
        
        //[self apply_random_special_texture_to_moveable_block: customized_wall_texture];
        
        [self runAction:
         [SKAction sequence:@[
                              [SKAction _waitForDuration:initalWaitDuration],
                              [SKAction repeatActionForever:
                               [SKAction sequence:@[
                                                    [SKAction _waitForDuration:loop_wait],
                                                [SKAction group:@[
                                                    [SKAction EaseInOutMoveByX:xDirection* originalWidth * (toX - 1) / 2 y: yDirection * originalHeight * (toY - 1)/ 2 duration:scale_duration],
                                                    [SKAction EaseInOutScaleXBy:toX y:toY duration:scale_duration]
                                                ]],
                                                    
                                                    
                                                [SKAction _waitForDuration:scale_wait],
                                                    
                                         [SKAction group:@[
                                            [SKAction EaseInOutMoveByX:- xDirection* originalWidth * (toX - 1) / 2 y: - yDirection* originalHeight * (toY - 1)/ 2 duration:scale_duration],
                                            [SKAction EaseInOutScaleXBy:1/toX y:1/toY duration:scale_duration]
                                         ]]
                                                    
                                                    
                                                    ]]]
                              ]]
         ];
    }
}

-(void)set_as_sand_block {
    self.isSand = YES;
    
    [self apply_random_special_texture_to_moveable_block:sand_ground_texture];
    
//    SKEmitterNode* sand_effect = [SKEmitterNode nodeWithFileNamed:@"sand_ground.sks"];
//    sand_effect.name = @"sand_effect";
//    sand_effect.position = CGPointMake(0, -self.size.height/2);
//    sand_effect.particlePositionRange = CGVectorMake(self.size.width, sand_effect.particlePositionRange.dy);
//    
//    [self addChild:sand_effect];
}

-(void)set_as_rotate_block:(NSString*) param {

    self.isGlass = YES;

    NSArray* ps = [param componentsSeparatedByString:@"/"];
    //index 0 for tag
    CGFloat initWait = ValueOfIndexInTextArray(ps, 1);
    CGFloat initAngle = ValueOfIndexInTextArray(ps, 2);
    CGFloat rotateAngle = ValueOfIndexInTextArray(ps, 3);
    CGFloat rotateDuration = ValueOfIndexInTextArray(ps, 4);
    CGFloat rotatedWait = ValueOfIndexInTextArray(ps, 5);
    
    [self runAction:[SKAction rotateByAngle:D_2_R(initAngle) duration:0]];
    
    [self runAction:[SKAction sequence:@[  [SKAction _waitForDuration:initWait],
                                           
                                           [SKAction repeatActionForever:
                                                    [SKAction sequence:@[
                                                                          [SKAction EaseInOutRotateByAngle:D_2_R(rotateAngle) duration:rotateDuration],
                                                                          [SKAction _waitForDuration:rotatedWait],
                                                                          
                                                                          [SKAction EaseInOutRotateByAngle:-D_2_R(rotateAngle) duration:rotateDuration],
                                                                          [SKAction _waitForDuration:rotatedWait]
                                                                        ]]

                                           ]
                                         ]]];
    
}

//////////////////////////////////////////////////////////////////////////////
-(void)setParameter: (NSString*)param {
    if ([param hasPrefix:@"mb"]) {     //mb1(1, 0)
        return [self set_as_moveable_block:[param substringFromIndex:2]];
    } else if ([param hasPrefix:@"vb/"]) {     //mb1(1, 0)
        return [self set_as_visible_block:[param substringFromIndex:[@"vb/" length]]];
    } else if ([param hasPrefix:@"sb/"]) {
        return [self set_as_scale_block: [param substringFromIndex:[@"sb/" length]]];
    } else if ([param hasPrefix:@"rb"]) {
        return [self set_as_rotate_block: [param substringFromIndex:2]];
    }
    
    /*else if ([param hasPrefix:@"sa"]) {
        return [self set_as_sand_block];
    }*/
    
    NSLog(@"unknown parameter: %@", param);
}

@end
