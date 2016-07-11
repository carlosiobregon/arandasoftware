//
//  iPadCollectionViewCell.m
//  arandasoftware
//
//  Created by Carlos Obregón on 11/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import "iPadCollectionViewCell.h"

@implementation iPadCollectionViewCell

+(NSString *)cellId{
    return NSStringFromClass(self);
}

-(void)prepareForReuse{
    
    self.imgSerie.image = nil;
    
}

@end
