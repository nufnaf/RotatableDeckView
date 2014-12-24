//
//  RotatableCardsView.m
//  Test3DCard
//
//  Created by qi zhang on 14/12/24.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import "RotatableDeckView.h"

@interface RotatableDeckView ()

@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, strong) NSMutableArray *initialTransformsOfCardViews;
@property (nonatomic, assign) NSUInteger numberOfCardViews;
@property (nonatomic, assign) CATransform3D remoteCardViewTransform;
@property (nonatomic, strong) UIView *viewToBeRemovedFromTop;

@end

@implementation RotatableDeckView

#pragma mark - public methods

- (void)reloadData
{
    NSUInteger i = 0;
    for (i= 0; i < [self.dataSource rotatableDeckViewNumberOfCardViews:self]; i++) {
        RotatableCardView *cardView = [self.dataSource rotatableDeckView:self cardViewForIndex:i];
        
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0f / - 1000.0f;
        t = CATransform3DTranslate(t, 2.0f * i, -6.0f * 2 * i,  -10.0f * 2 * i);
        cardView.layer.transform = t;
        [self.initialTransformsOfCardViews addObject:[NSValue valueWithCATransform3D:t]];
        
        cardView.rotateAnimationCompletionBlock = ^(){
            [self insertSubview:self.viewToBeRemovedFromTop belowSubview:self.cardViews[self.numberOfCardViews - 1]];
            [self.cardViews removeObject:self.viewToBeRemovedFromTop];
            [self.cardViews addObject:self.viewToBeRemovedFromTop];
            
            for (NSUInteger i = 0; i < self.cardViews.count - 1; i++) {
                [self moveViewUpward:self.cardViews[i] animated:YES];
            }
            [self moveViewToBottom:self.viewToBeRemovedFromTop animated:YES];
        };
    }
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DIdentity;
    t.m34 = 1.0f / - 1000.0f;
    t = CATransform3DTranslate(_remoteCardViewTransform, 2.0f * 3, -6.0f * 2 * 3,  -10.0f * 2 * 3);
    self.remoteCardViewTransform = t;
}


#pragma mark - private methods

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
