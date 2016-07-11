//
//  iPadCollectionViewCell.h
//  arandasoftware
//
//  Created by Carlos Obregón on 11/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgSerie;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (weak, nonatomic) IBOutlet UILabel *lblNameSerie;

+(NSString *)cellId;
@end
