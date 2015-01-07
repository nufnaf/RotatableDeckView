//
//  RotatableCardsView.h
//  Test3DCard
//
//  Created by qi zhang on 14/12/24.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableCardView.h"

@class RotatableDeckView;
@protocol RotatableDeckViewDataSource <NSObject>

- (NSUInteger)rotatableDeckViewNumberOfCardViews:(RotatableDeckView *)rotatableDeckView;
- (NSUInteger)rotatableDeckViewNumberOfVisibleCardViews:(RotatableDeckView *)rotatableDeckView;
- (RotatableCardView *)rotatableDeckView:(RotatableDeckView *)rotatableDeckView cardViewForIndex:(NSUInteger)index;

@end

@interface RotatableDeckView : UIView

@property (nonatomic, weak) id<RotatableDeckViewDataSource> dataSource;

- (RotatableCardView *)dequeueReusableCellsWithIdentifier:(NSString *)identifier;
- (void)reloadData;

@end
