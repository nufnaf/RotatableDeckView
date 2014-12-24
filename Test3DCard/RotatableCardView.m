//
//  RotatableCardView.m
//  Test3DCard
//
//  Created by qi zhang on 14/12/24.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import "RotatableCardView.h"

#define kRemoveViewFromTopAnimation @"RemoveViewFromTopAnimation"

@interface RotatableCardView ()

@property (nonatomic, assign) CATransform3D tranformWhenPanBegan;
@property (nonatomic, assign) double angleToRotate;

@end

@implementation RotatableCardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}


#pragma mark - private methods

- (void)commonInit
{
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardViewPaned:)];
    [self addGestureRecognizer:pgr];
}

- (void)removeViewFromTop:(UIView *)view animated:(BOOL)animated
{
    CATransform3D t = self.tranformWhenPanBegan;
    t.m34 = 1.0f / - 1000.0f;
    t = CATransform3DRotate(t, M_PI_2, 0, 0, 1);
    if (animated) {
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [transformAnimation setFromValue:[NSValue valueWithCATransform3D:view.layer.transform]];
        [transformAnimation setToValue:[NSValue valueWithCATransform3D:t]];
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @(view.layer.opacity);
        alphaAnimation.toValue = @0;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[transformAnimation, alphaAnimation];
        [animationGroup setDuration:0.3];
        [animationGroup setValue:kRemoveViewFromTopAnimation forKey:@"animationName"];
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.delegate = self;
        
        [view.layer addAnimation:animationGroup forKey:nil];
    }
    view.layer.transform = t;
    view.layer.opacity = 0;
}

- (void)resetViewToTop:(UIView *)view animated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *resetTransformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [resetTransformAnimation setFromValue:[NSValue valueWithCATransform3D:view.layer.transform]];
        [resetTransformAnimation setToValue:[NSValue valueWithCATransform3D:self.tranformWhenPanBegan]];
        
        CABasicAnimation *resetAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        resetAlphaAnimation.fromValue = @(view.layer.opacity);
        resetAlphaAnimation.toValue = @1;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[resetTransformAnimation, resetAlphaAnimation];
        [animationGroup setDuration:0.3];
        animationGroup.fillMode = kCAFillModeForwards;
        
        [view.layer addAnimation:animationGroup forKey:nil];
    }
    view.layer.transform = self.tranformWhenPanBegan;
    view.layer.opacity = 1;
}


#pragma mark - gesture handler

- (void)cardViewPaned:(id)sender
{
    UIPanGestureRecognizer *pgr = sender;
    switch (pgr.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.tranformWhenPanBegan = self.layer.transform;
        }
            
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentPoint = [pgr translationInView:pgr.view];
            self.angleToRotate = currentPoint.x / (1.2 * sqrt(pow(pgr.view.bounds.size.width, 2) + pow(pgr.view.bounds.size.height, 2))) * M_PI_2;
            CATransform3D t = self.tranformWhenPanBegan;
            t.m34 = 1.0f / - 1000.0f;
            t = CATransform3DRotate(t, _angleToRotate, 0, 0, 1);
            pgr.view.layer.transform = t;
            pgr.view.layer.opacity = 1 - _angleToRotate / M_PI_2;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (_angleToRotate >= (M_PI / 6) || [pgr velocityInView:self.window].x > 1000) {
                [self removeViewFromTop:pgr.view animated:YES];
            } else {
                [self resetViewToTop:pgr.view animated:YES];
            }
        }
            break;
        default:
            break;
    }
    if (pgr.state == UIGestureRecognizerStateChanged) {
        
    }
    if (pgr.state == UIGestureRecognizerStateEnded) {
        
    }
}


#pragma mark - animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"animationName"] isEqualToString:kRemoveViewFromTopAnimation]) {
        if (self.rotateAnimationCompletionBlock) {
            self.rotateAnimationCompletionBlock();
        }
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

@end
