//
//  common.h
//  findit
//
//  Created by Hongmin Wang on 1/5/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#ifndef findit_common_h
#define findit_common_h

#import <SpriteKit/SpriteKit.h>

#define DEBUG_VERSION

typedef enum e_btn {
    e_left, e_right, e_jump, e_fire, e_reload, e_undown
} e_btn;

static const uint32_t hero_category = 0x01 << 1;
static const uint32_t ground_category = 0x01 << 2;
static const uint32_t monster_category = 0x01 << 3;
static const uint32_t bullet_category = 0x01 << 4;
static const uint32_t game_final_category = 0x01 << 5;
static const uint32_t star_category = 0x01 << 6;
static const uint32_t heart_category = 0x01 << 7;
static const uint32_t bomb_category = 0x01 << 8;
static const uint32_t key_category = 0x01 << 9;
static const uint32_t spikes_category = 0x01 << 10;
static const uint32_t laser_category = 0x01 << 11;
static const uint32_t decoration_category = 0x01 << 12;
static const uint32_t balloon_category = 0x01 << 13;

static const CGFloat k_hero_zposition = 1500;

////////////////////////////////////////////////////////////////////////////////
#define cDefaultFloatComparisonEpsilon    0.000001
#define cEqualFloats(f1, f2)    ( fabs( (f1) - (f2) ) < cDefaultFloatComparisonEpsilon )
#define cNotEqualFloats(f1, f2)    ( !cEqualFloats(f1, f2, cDefaultFloatComparisonEpsilon))
#define R_2_D(radians) ((radians) * (180.0 / M_PI))
#define D_2_R(angle) ((angle) / 180.0 * M_PI)

///////////////////////////////////////////////////////////////////////////////
@interface SKAction(EaseInOut)
+ (SKAction *)EaseInOutMoveByX:(CGFloat)deltaX y:(CGFloat)deltaY duration:(NSTimeInterval)sec;
+ (SKAction *)EaseInOutRotateByAngle:(CGFloat)radians duration:(NSTimeInterval)sec;
+ (SKAction *)EaseInOutScaleXBy:(CGFloat)xScale y:(CGFloat)yScale duration:(NSTimeInterval)sec;
+ (SKAction *)_waitForDuration:(CGFloat)duration;
@end


////////////////////////////////////////////////////////////////////////////////
@interface SKColor(Hexadecimal)
+ (SKColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
+ (SKColor *)randomColor;
@end


////////////////////////////////////////////////////////////////////////////////
CGFloat DistanceBetweenPoints(CGPoint first, CGPoint second);
CGFloat ValueOfIndexInTextArray(NSArray* arr, int index);
CGFloat ValueOfIndexInTextArrayWithDefaultValue(NSArray* arr, int index, CGFloat defaultValue);

////////////////////////////////////////////////////////////////////////////////
@protocol SKContactable<NSObject>
- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact;
-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact;
@end

@protocol Hurtable<NSObject>
-(void)hurtby:(SKSpriteNode*)hurtSource with:(int)hurt;
@end

@protocol Customizeable<NSObject>
-(void)setParameter: (NSString*)param;
@end


@protocol GameApp<NSObject>
- (void)game_over;
- (void)before_enter_new_level: (CGPoint)level_position;
- (void)game_victory;
- (void)restart_to_level:(NSString*)levelName;
- (SKPhysicsWorld*)current_physics_world;
- (void)update_hero_health_to:(int)health_value;
- (void)update_hero_bullet_count_to:(NSString*)count;
@end

@protocol Updatable<NSObject>
-(void)update:(CFTimeInterval)currentTime;
@end


#endif
