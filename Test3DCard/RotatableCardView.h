//
//  RotatableCardView.h
//  Test3DCard
//
//  Created by qi zhang on 14/12/24.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RotateAnimationCompletionBlock)();

@interface RotatableCardView : UIView

@property (nonatomic, strong) RotateAnimationCompletionBlock rotateAnimationCompletionBlock;

@end
