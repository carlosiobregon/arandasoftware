//
//  CIODetalleSerieVC.h
//  arandasoftware
//
//  Created by Carlos Obregón on 11/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIODetalleSerieVC : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *serie;
@property (nonatomic, strong) UISegmentedControl *mySegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblGenre;

@property (weak, nonatomic) IBOutlet UILabel *lblActors;
@property (weak, nonatomic) IBOutlet UILabel *lblEpisodios;

@property (weak, nonatomic) IBOutlet UITableView *listCapitulos;
@property (weak, nonatomic) IBOutlet UIImageView *imgSerie;
@end
