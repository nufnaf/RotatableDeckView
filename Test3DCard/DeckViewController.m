//
//  DeckViewController.m
//  Test3DCard
//
//  Created by qi zhang on 14/12/27.
//  Copyright (c) 2014年 qi zhang. All rights reserved.
//

#import "DeckViewController.h"
#import "RotatableDeckView.h"

@interface DeckViewController () <RotatableDeckViewDataSource>

@end

@implementation DeckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RotatableDeckView *deckview = [[RotatableDeckView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:deckview];
    deckview.dataSource = self;
    [deckview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)rotatableDeckViewNumberOfCardViews:(RotatableDeckView *)rotatableDeckView
{
    return 6;
}

- (RotatableCardView *)rotatableDeckView:(RotatableDeckView *)rotatableDeckView cardViewForIndex:(NSUInteger)index
{
    UIColor *color;
    RotatableCardView *view = [[RotatableCardView alloc] initWithFrame:(CGRect){50, 50, 200, 400}];
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, 200, 20}];
    switch (index) {
        case 0:
            color = [UIColor redColor];
            label.text = @"this is the first view";
            break;
        case 1:
            color = [UIColor greenColor];
            label.text = @"this is the second view";
            break;
        case 2:
            color = [UIColor blueColor];
            label.text = @"this is the third view";
            break;
        case 3:
            color = [UIColor yellowColor];
            label.text = @"this is the fourth view";
            break;
        case 4:
            color = [UIColor purpleColor];
            label.text = @"this is the fifth view";
            break;
        case 5:
            color = [UIColor orangeColor];
            label.text = @"this is the sixth view";
            break;
        default:
            break;
    }
    [view addSubview:label];
    view.backgroundColor = color;
    return view;
}

- (NSUInteger)rotatableDeckViewNumberOfVisibleCardViews:(RotatableDeckView *)rotatableDeckView
{
    return 3;
}

@end
