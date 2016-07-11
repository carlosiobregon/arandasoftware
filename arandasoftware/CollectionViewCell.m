//
//  CollectionViewCell.m
//  collevtionViewWithSearchBar
//
//  Created by Homam on 2015-01-02.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

+(NSString *)cellId{
    return NSStringFromClass(self);
}

-(void)prepareForReuse{

    self.imgSerie.image = nil;
    
}
@end