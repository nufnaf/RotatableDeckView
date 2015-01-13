//
//  RotatableCardsView.m
//  Test3DCard
//
//  Created by qi zhang on 14/12/24.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import "RotatableDeckView.h"

@interface RotatableDeckView ()

@property (nonatomic, strong) NSMutableDictionary *reusableIdentifier2CardView;
@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, strong) NSMutableArray *initialTransformsOfCardViews;
@property (nonatomic, assign) NSUInteger numberOfCardViews;
@property (nonatomic, assign) CATransform3D remoteCardViewTransform;
@property (nonatomic, assign) NSUInteger currentCardViewIndex;

@end

@implementation RotatableDeckView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cardViews = [NSMutableArray array];
        self.initialTransformsOfCardViews = [NSMutableArray array];
        self.reusableIdentifier2CardView = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - public methods

- (void)reloadData
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.cardViews removeAllObjects];
    self.numberOfCardViews = [self.dataSource rotatableDeckViewNumberOfVisibleCardViews:self];
    self.currentCardViewIndex = self.numberOfCardViews - 1;
    NSUInteger i = 0;
    for (i= 0; i < self.numberOfCardViews; i++) {
        RotatableCardView *cardView = [self.dataSource rotatableDeckView:self cardViewForIndex:i];
        if (i == 0) {
            [self addSubview:cardView];
        } else {
            [self insertSubview:cardView belowSubview:self.cardViews.lastObject];
        }
        [self addCardView:cardView];
        
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0f / - 1000.0f;
        t = CATransform3DTranslate(t, 2.0f * i, -6.0f * 2 * i,  -10.0f * 2 * i);
        cardView.layer.transform = t;
        [self.initialTransformsOfCardViews addObject:[NSValue valueWithCATransform3D:t]];
        cardView.rotateAnimationCompletionBlock = [self cardViewRotationCompletionBlockWith:cardView];
    }
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DIdentity;
    t.m34 = 1.0f / - 1000.0f;
    t = CATransform3DTranslate(_remoteCardViewTransform, 2.0f * i, -6.0f * 2 * i,  -10.0f * 2 * i);
    self.remoteCardViewTransform = t;
}

- (RotatableCardView *)dequeueReusableCellsWithIdentifier:(NSString *)identifier
{
    NSMutableArray *reusableQueue = self.reusableIdentifier2CardView[identifier];
    RotatableCardView *cardView = reusableQueue.firstObject;
    [reusableQueue removeObject:cardView];
    return cardView;
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

- (RotateAnimationCompletionBlock)cardViewRotationCompletionBlockWith:(RotatableCardView *)cardView
{
    __weak typeof(self) weakSelf = self;
    __weak typeof(cardView) weakCardView = cardView;
    RotateAnimationCompletionBlock block = ^(){
        if (weakCardView.reusableIdentifier.length) {
            NSMutableArray *reusableQueue = self.reusableIdentifier2CardView[weakCardView.reusableIdentifier];
            if (!reusableQueue) {
                reusableQueue = [NSMutableArray array];
                [self.reusableIdentifier2CardView setObject:reusableQueue forKey:weakCardView.reusableIdentifier];
            }
            [reusableQueue addObject:weakCardView];
        }
        [weakSelf.cardViews removeObject:weakCardView];
        
        
        for (NSUInteger i = 0; i < weakSelf.cardViews.count; i++) {
            [weakSelf moveViewUpward:weakSelf.cardViews[i] animated:YES];
        }
        if (weakSelf.currentCardViewIndex + 1 < [weakSelf.dataSource rotatableDeckViewNumberOfCardViews:weakSelf]) {
            RotatableCardView *nextCardView = [weakSelf.dataSource rotatableDeckView:weakSelf cardViewForIndex:weakSelf.currentCardViewIndex + 1];
            nextCardView.layer.transform = CATransform3DIdentity;
            [weakSelf insertSubview:nextCardView belowSubview:self.cardViews.lastObject];
            [weakSelf addCardView:nextCardView];
            [weakSelf moveViewToBottom:nextCardView animated:YES];
        }
        
        weakSelf.currentCardViewIndex++;
    };
    return block;
}

- (void)addCardView:(RotatableCardView *)cardView
{
    [self.cardViews addObject:cardView];
    
    CGRect originalCardViewFrame = cardView.frame;
    cardView.layer.anchorPoint = CGPointMake(0, 1);
    cardView.frame = originalCardViewFrame;
    cardView.rotateAnimationCompletionBlock = [self cardViewRotationCompletionBlockWith:cardView];
}


@end
