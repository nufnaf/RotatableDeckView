//
//  CardsViewController.m
//  Test3DCard
//
//  Created by qi zhang on 1/13/15.
//  Copyright (c) 2015 qi zhang. All rights reserved.
//

#import "CardsViewController.h"
#import "RotatableDeckView.h"

@interface CardsViewController () <RotatableDeckViewDataSource>

@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, strong) NSArray *imageURLStringArray;

@end

@implementation CardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RotatableDeckView *deckView = [[RotatableDeckView alloc] initWithFrame:CGRectInset(self.view.bounds, 10, 30)];
    deckView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:deckView];
    self.view.backgroundColor = [UIColor lightTextColor];
    
    self.textArray = @[@"This is the first", @"This is the second", @"This is the third", @"This is the 4th", @"This is the 5th", @"This is the 6th", @"This is the 7th", @"This is the 8th", @"This is the 9th", @"This is the 10th"];
    self.imageURLStringArray = @[@"http://img2.imgtn.bdimg.com/it/u=2688546271,1508054677&fm=23&gp=0.jpg", @"http://img4.imgtn.bdimg.com/it/u=3607456349,28056161&fm=23&gp=0.jpg", @"http://img5.imgtn.bdimg.com/it/u=3402847872,3071334627&fm=23&gp=0.jpg", @"http://img4.imgtn.bdimg.com/it/u=4265826380,2456455206&fm=23&gp=0.jpg", @"http://img0.imgtn.bdimg.com/it/u=3674713923,267564897&fm=23&gp=0.jpg", @"http://img2.imgtn.bdimg.com/it/u=3734723388,3056975550&fm=23&gp=0.jpg", @"http://img0.imgtn.bdimg.com/it/u=220488181,1975935731&fm=23&gp=0.jpg", @"http://img4.imgtn.bdimg.com/it/u=1717094639,1881006701&fm=23&gp=0.jpg", @"http://img4.imgtn.bdimg.com/it/u=3129323502,4201213190&fm=23&gp=0.jpg", @"http://img3.imgtn.bdimg.com/it/u=333677645,1914684100&fm=23&gp=0.jpg"];
    
    deckView.dataSource = self;
    [deckView reloadData];
}

- (NSUInteger)rotatableDeckViewNumberOfCardViews:(RotatableDeckView *)rotatableDeckView
{
    return 10;
}
- (NSUInteger)rotatableDeckViewNumberOfVisibleCardViews:(RotatableDeckView *)rotatableDeckView
{
    return 4;
}
- (RotatableCardView *)rotatableDeckView:(RotatableDeckView *)rotatableDeckView cardViewForIndex:(NSUInteger)index
{
    static NSString *identifier = @"RotatableCardViewIdentifier";
    RotatableCardView *cardView = [rotatableDeckView dequeueReusableCellsWithIdentifier:identifier];
    if (!cardView) {
        cardView = [[RotatableCardView alloc] initWithFrame:rotatableDeckView.bounds];
        cardView.reusableIdentifier = identifier;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, cardView.bounds.size.width, 30)];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor blueColor];
        label.tag = 1501030953;
        [cardView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, cardView.bounds.size.width, cardView.bounds.size.height - 30)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.tag = 1501031011;
        
        [cardView addSubview:imageView];
    }
//    cardView.frame = rotatableDeckView.bounds;
    UILabel *label = (UILabel *)[cardView viewWithTag:1501030953];
    label.text = self.textArray[index];

    UIImageView *imageView = (UIImageView *)[cardView viewWithTag:1501031011];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    [imageView setImage:image];
    return cardView;
}

@end
