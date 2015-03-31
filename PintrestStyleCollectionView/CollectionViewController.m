//
//  CollectionViewController.m
//  PintrestStyleCollectionView
//
//  Created by Jonathan Goldsmith on 3/30/15.
//  Copyright (c) 2015 JonathanGoldsmith. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface CollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic,assign) CGFloat scale;
//@property (nonatomic,strong)     NSIndexPath *indexPathOfStartPoint;



@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"PintrestCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scale = 1.0;
    
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [self.collectionView addGestureRecognizer:gesture];
    
    
    if(!self.imageArray) {
        [self getPictures];
    }
    
}


- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
    static CGFloat scaleStart;
    //NSIndexPath *indexPathOfEndPoint;
    
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        scaleStart = self.scale;
       // self.indexPathOfStartPoint = [self.collectionView indexPathForItemAtPoint:[gesture locationInView: self.collectionView]];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGFloat temp = scaleStart * gesture.scale;
        if (temp <= 2 && temp >= 0.6) {
            self.scale = scaleStart * gesture.scale;
        } else if(temp > 2 ) {
            self.scale = 2;
            
            //attempts at making the cells switch positions, origonally I had this as "else if (gesture.state == UIGestureStateEnded)" to pick up the locations, but I couldnt get the indexPathsOfEnd/Start to work properly.
            
            /*indexPathOfEndPoint = [self.collectionView indexPathForItemAtPoint:[gesture locationInView: self.collectionView]];
            if(self.indexPathOfStartPoint != indexPathOfEndPoint) {
                NSMutableArray *temp = [self.imageArray mutableCopy];
                NSString *beginningObjectToReplace = [self.imageArray objectAtIndex:0];
                NSString *EndObjectToReplace = [temp objectAtIndex:self.imageArray.count-1];
                [temp replaceObjectAtIndex:0 withObject:[temp objectAtIndex:self.indexPathOfStartPoint.row]];
                [temp replaceObjectAtIndex:self.imageArray.count-1 withObject:[temp objectAtIndex:indexPathOfEndPoint.row]];
                [temp replaceObjectAtIndex:self.indexPathOfStartPoint.row withObject:beginningObjectToReplace];
                [temp replaceObjectAtIndex:indexPathOfEndPoint.row withObject:EndObjectToReplace];
                self.imageArray = temp;
                [self.collectionView reloadData];
            }
             */
        }
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPictures {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PinterestImagesJSON" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.imageArray = [json valueForKeyPath:@"pinterestImages"];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderWidth = 2.0;
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    
    cell.maskView.clipsToBounds = YES;
    
    [cell.pinterestCellImage sd_setImageWithURL:[NSURL URLWithString:[self.imageArray objectAtIndex:[indexPath row]]]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.scale == 2) {
        return CGSizeMake(collectionViewLayout.collectionView.bounds.size.width,collectionViewLayout.collectionView.bounds.size.height);
    }
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        if(indexPath.row%2) {
            return CGSizeMake(270.f*self.scale, 270.f*self.scale);

        } else {
            return CGSizeMake(250.f*self.scale, 250.f*self.scale);

        }
    } else {
        if(indexPath.row%2) {
            return CGSizeMake(220.f*self.scale, 220.f*self.scale);
            
        } else {
            return CGSizeMake(250.f*self.scale, 250.f*self.scale);
        }
    }}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

@end
