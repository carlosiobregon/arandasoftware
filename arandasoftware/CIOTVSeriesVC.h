//
//  CIOTVSeriesVC.h
//  arandasoftware
//
//  Created by Carlos Obregón on 7/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIOTVSeriesVC : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UITextField *tfBusqueda;
@property (weak, nonatomic) IBOutlet UICollectionView *seriesCV;

- (IBAction)buscarSerie:(id)sender;
@end
