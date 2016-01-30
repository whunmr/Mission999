//
//  Monster.m
//  findit
//
//  Created by Hongmin Wang on 1/8/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.


#import "Monster.h"
#import "common.h"
#import "GameScene.h"
#import "HMHero.h"
#import "Heart.h"

enum MonsterPosition {
    on_left_end_of_ground,
    on_right_end_of_ground,
    unknown_end
};

@interface Monster()
@property SKSpriteNode* left_eye;
@property SKSpriteNode* right_eye;
@property SKSpriteNode* mouth;
@property CFTimeInterval last_active_time;

@property int horizental_move_direction;
@property CGFloat last_xpos;
@property enum MonsterPosition pos_on_ground;

@property int health;
@end

@implementation Monster
static SKAction* actionHitByBulletSound;
static SKAction* actionMonsterHurtSound;
static SKTexture* monster_texture_left;
static SKTexture* monster_texture_right;

+ (void)initialize {
        actionMonsterHurtSound = [SKAction playSoundFileNamed:@"monster_die.mp3" waitForCompletion:NO];
        monster_texture_left = [SKTexture textureWithImageNamed:@"monster1_left.png"];
        monster_texture_right = [SKTexture textureWithImageNamed:@"monster1_right.png"];
}

+(Monster*)monster {
    //Monster* m = [[Monster alloc] initWithColor:[SKColor randomColor]
    //                                     size:CGSizeMake(20.0, 20.0)];
    Monster* m = [[Monster alloc] initWithImageNamed:@"monster1_left.png"];
    
    m.health = 1;

    m.horizental_move_direction = arc4random_uniform(3) - 1; //make it move right（1）, left (-1）
    m.horizental_move_direction = 1;
    m.texture = monster_texture_right;
    
    m.pos_on_ground = unknown_end;
    
    m.xScale = m.yScale = 20 / m.size.width;
    
    m.name = @"monster";
    
    /*m.left_eye = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(2.5, 2.5)];
    m.right_eye = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(2.5, 2.5)];
    m.mouth = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(10, 3.5)];
    
    m.left_eye.position = CGPointMake(-2, 2.5);
    m.right_eye.position = CGPointMake(3, 2.5);
    m.mouth.position = CGPointMake(0.5, -4.5);
    
    [m addChild:m.left_eye];
    [m addChild:m.right_eye];
    [m addChild:m.mouth];
    */
    
    m.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:m.size];
    m.physicsBody.allowsRotation = NO;
    m.physicsBody.restitution = 0.0;
    m.physicsBody.dynamic = YES;
    m.physicsBody.friction = 0.99;
    m.physicsBody.linearDamping = 1;
    m.physicsBody.categoryBitMask = monster_category;
    m.physicsBody.collisionBitMask = hero_category | ground_category | bullet_category | monster_category;
    m.physicsBody.contactTestBitMask = hero_category | bullet_category;
    m.physicsBody.fieldBitMask = 0;
    
    //NSLog(@"----> %f", m.physicsBody.mass); //0.017778
    
    return m;
}


-(enum MonsterPosition)pos {

  NSArray* arr = [self.parent nodesAtPoint:CGPointMake(self.position.x - self.size.width/2, self.position.y - self.size.height/2 - 5)];
  for (SKNode* n in arr) {
    if ([n.name isEqualToString:@"ground"]) {
        SKSpriteNode* nn = (SKSpriteNode*)n;
        if (self.position.x + self.size.width > nn.position.x + nn.size.width/2 - 3) {
            return on_right_end_of_ground;
        }
        if (self.position.x - self.size.width < nn.position.x - nn.size.width/2 + 3) {
            return on_left_end_of_ground;
        }
    }
  }
    
    return unknown_end;
}

- (void) apply_force__and__record_last_position {
    [self.physicsBody applyImpulse:CGVectorMake(0.2 * self.horizental_move_direction, 0)];
    self.last_xpos = self.position.x;
}

-(void)change_move_direction {
    self.physicsBody.velocity = CGVectorMake(0, 0);
    
    self.horizental_move_direction = (self.pos_on_ground == unknown_end) ? -self.horizental_move_direction
    : (self.pos_on_ground == on_left_end_of_ground) ? 1
    : -1;
    
    if (self.horizental_move_direction == 1) {
        self.texture = monster_texture_right;
    } else if (self.horizental_move_direction == -1) {
        self.texture = monster_texture_left;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if (currentTime - self.last_active_time > 0.125) {
                
        self.last_active_time = currentTime;
        self.pos_on_ground = [self pos];
        
        if (self.pos_on_ground != unknown_end) {
            if (self.pos_on_ground == on_right_end_of_ground) {
                SKNode* n = [self.parent nodeAtPoint:CGPointMake(self.position.x - self.size.width/2 - 3, self.position.y)];
                if ([n.name isEqualToString:@"monster"]) {
                    self.physicsBody.dynamic = NO;
                    return;
                } else {
                    self.physicsBody.dynamic = YES;
                }
            }
            
            if (self.pos_on_ground == on_left_end_of_ground) {
                SKNode* n = [self.parent nodeAtPoint:CGPointMake(self.position.x + self.size.width/2 + 3, self.position.y)];
                if ([n.name isEqualToString:@"monster"]) {
                    self.physicsBody.dynamic = NO;
                    return;
                } else {
                    self.physicsBody.dynamic = YES;
                }
            }
            
            [self change_move_direction];
            return [self apply_force__and__record_last_position];
        }
        
        if (fabs(self.last_xpos - self.position.x) < 1) {
            [self change_move_direction];
        }
        
        [self apply_force__and__record_last_position];
    }
}

-(void)hurtby:(SKSpriteNode*)hurtSource with:(int)hurt {
    if (self.health <= 0) {
        return;
    }
    
    self.health -= hurt;
    
    if ( ! [self childNodeWithName:@"HurtEffect"]) {
        SKEmitterNode* HurtEffect = [SKEmitterNode nodeWithFileNamed:@"after_hurt.sks"];
        HurtEffect.name = @"HurtEffect";

        [self addChild:HurtEffect];
        [self runAction:
         [SKAction sequence:@[
                              [SKAction _waitForDuration:0.3],
                              [SKAction runBlock:^{
             [HurtEffect removeFromParent];
         }]
                              ]]
         ];
    }
    
    if (self.health <= 0) {
        if (arc4random_uniform(100) > 75) {  //TODO: random drop things system.
            Heart* heart = [Heart new_disapearable_heart:self.position];
            [self.parent addChild:heart];
        }
        
        [self runAction:[SKAction sequence:@[actionMonsterHurtSound, [SKAction removeFromParent]]]];
    } else {
        [self runAction: actionMonsterHurtSound];
    }
}

///////////////////////////////////////////////////////////////////////
- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    //if (contact.contactNormal.dy == 0) {
    //if ([body.node.name isEqualToString:@"monster"]) {
    //}
    //}
    if ([self pos_on_ground] == unknown_end) {
        [self change_move_direction];
    }
    
    if ([body.node.name isEqualToString:@"hero"]) {
        [[HMHero hero] hurtby:self with:1]; //TODO: 20 to contact force.
        return;
    }
    
    if ([body.node.name isEqualToString:@"bullet"]) {
        [self hurtby:nil with:1];
        
        [body.node removeFromParent];
        
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
    } else {
        NSLog(@"monster hit %@", body.node.name);
    }
    
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}
@end
