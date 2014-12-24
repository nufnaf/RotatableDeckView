//
//  ViewController.m
//  Test3DCard
//
//  Created by qi zhang on 14/12/20.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import "ViewController.h"

#define kRemoveViewFromTopAnimation @"RemoveViewFromTopAnimation"

@interface ViewController () {
    CATransform3D _remoteCardViewTransform;
    CGPoint _panGestureStartPoint;
    float _angleToRotate;
    
}

@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, strong) NSMutableArray *initialTransformsOfCardViews;
@property (nonatomic, assign) NSUInteger numberOfCardViews;
@property (nonatomic, strong) UIView *viewToBeRemovedFromTop;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfCardViews = 3;
    self.cardViews = [NSMutableArray array];
    self.initialTransformsOfCardViews = [NSMutableArray array];
    [self addCardWithColor:[UIColor redColor]];
    [self addCardWithColor:[UIColor blueColor]];
    [self addCardWithColor:[UIColor greenColor]];

    for (NSUInteger i = 0; i < self.numberOfCardViews + 1; i++) {
        if (i == self.numberOfCardViews) {
            _remoteCardViewTransform = CATransform3DIdentity;
            _remoteCardViewTransform.m34 = 1.0f / - 1000.0f;
            _remoteCardViewTransform = CATransform3DTranslate(_remoteCardViewTransform, 2.0f * 3, -6.0f * 2 * 3,  -10.0f * 2 * 3);
            break;
        }
        UIView *cardView = self.cardViews[i];
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0f / - 1000.0f;
        t = CATransform3DTranslate(t, 2.0f * i, -6.0f * 2 * i,  -10.0f * 2 * i);
        cardView.layer.transform = t;
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardViewPaned:)];
        [cardView addGestureRecognizer:pgr];
        [self.initialTransformsOfCardViews addObject:[NSValue valueWithCATransform3D:t]];
    }
}

- (void)addCardWithColor:(UIColor *)color
{
    UIView *cardView = [[UIView alloc] init];
    cardView.layer.anchorPoint = CGPointMake(0, 1);
    cardView.layer.cornerRadius = 4;
    cardView.clipsToBounds = YES;
    cardView.frame = (CGRect){(self.view.bounds.size.width - 180) / 2, (self.view.bounds.size.height - 320) / 2, 180, 320};
    cardView.backgroundColor = color;
    if (self.cardViews.count) {
        [self.view insertSubview:cardView belowSubview:self.cardViews.lastObject];
    } else {
        [self.view addSubview:cardView];
    }
    
    [self.cardViews addObject:cardView];
}

- (void)cardViewPaned:(id)sender
{
    UIPanGestureRecognizer *pgr = sender;
    NSLog(@"%@", NSStringFromCGPoint([pgr velocityInView:self.view]));
    if (pgr.state == UIGestureRecognizerStateBegan) {
        _panGestureStartPoint = [pgr translationInView:pgr.view];
    }
    if (pgr.state == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [pgr translationInView:pgr.view];
        _angleToRotate = (currentPoint.x - _panGestureStartPoint.x) / (1.2 * sqrt(pow(pgr.view.bounds.size.width, 2) + pow(pgr.view.bounds.size.height, 2))) * M_PI_2;
        CATransform3D t = [self.initialTransformsOfCardViews[[self.cardViews indexOfObject:pgr.view]] CATransform3DValue];
        t.m34 = 1.0f / - 1000.0f;
        t = CATransform3DRotate(t, _angleToRotate, 0, 0, 1);
        pgr.view.layer.transform = t;
        pgr.view.layer.opacity = 1 - _angleToRotate / M_PI_2;
    }
    if (pgr.state == UIGestureRecognizerStateEnded) {
        if (_angleToRotate >= (M_PI / 6) || [pgr velocityInView:self.view].x > 1000) {
            [self removeViewFromTop:pgr.view animated:YES];
        } else {
            [self resetViewToTop:pgr.view animated:YES];
        }
    }
}

#pragma mark - animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"animationName"] isEqualToString:kRemoveViewFromTopAnimation]) {
        [self.view insertSubview:self.viewToBeRemovedFromTop belowSubview:self.cardViews[self.numberOfCardViews - 1]];
        [self.cardViews removeObject:self.viewToBeRemovedFromTop];
        [self.cardViews addObject:self.viewToBeRemovedFromTop];

        for (NSUInteger i = 0; i < self.cardViews.count - 1; i++) {
            [self moveViewUpward:self.cardViews[i] animated:YES];
        }
        [self moveViewToBottom:self.viewToBeRemovedFromTop animated:YES];
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}


#pragma mark - private methods

- (void)removeViewFromTop:(UIView *)view animated:(BOOL)animated
{
    self.viewToBeRemovedFromTop = view;
    CATransform3D t = [self.initialTransformsOfCardViews[[self.cardViews indexOfObject:view]] CATransform3DValue];
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
        [resetTransformAnimation setToValue:[NSValue valueWithCATransform3D:[self.initialTransformsOfCardViews[[self.cardViews indexOfObject:view]] CATransform3DValue]]];
        
        CABasicAnimation *resetAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        resetAlphaAnimation.fromValue = @(view.layer.opacity);
        resetAlphaAnimation.toValue = @1;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[resetTransformAnimation, resetAlphaAnimation];
        [animationGroup setDuration:0.3];
        animationGroup.fillMode = kCAFillModeForwards;
        
        [view.layer addAnimation:animationGroup forKey:nil];
    }
    view.layer.transform = [self.initialTransformsOfCardViews[[self.cardViews indexOfObject:view]] CATransform3DValue];
    view.layer.opacity = 1;
}

- (void)moveViewToBottom:(UIView *)view animated:(BOOL)animated
{
    CATransform3D t = [[self.initialTransformsOfCardViews lastObject] CATransform3DValue];
    if (animated) {
        view.layer.transform = _remoteCardViewTransform;
        view.layer.opacity = 0.0;
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [transformAnimation setFromValue:[NSValue valueWithCATransform3D:view.layer.transform]];
        [transformAnimation setToValue:[NSValue valueWithCATransform3D:t]];
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @(view.layer.opacity);
        alphaAnimation.toValue = @1;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[transformAnimation, alphaAnimation];
        [animationGroup setDuration:0.15];
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.delegate = self;
        
        [view.layer addAnimation:animationGroup forKey:nil];
    }
    view.layer.transform = t;
    view.layer.opacity = 1;
}

- (void)moveViewUpward:(UIView *)view animated:(BOOL)animated
{
    CATransform3D t = [self.initialTransformsOfCardViews[[self.cardViews indexOfObject:view]] CATransform3DValue];
    if (animated) {
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [transformAnimation setFromValue:[NSValue valueWithCATransform3D:view.layer.transform]];
        [transformAnimation setToValue:[NSValue valueWithCATransform3D:t]];

        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[transformAnimation];
        [animationGroup setDuration:0.15];
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.delegate = self;
        
        [view.layer addAnimation:animationGroup forKey:nil];
    }
    view.layer.transform = t;
}

@end
