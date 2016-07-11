//
//  CIODetalleSerieVC.m
//  arandasoftware
//
//  Created by Carlos Obregón on 11/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import "CIODetalleSerieVC.h"
#import "MBProgressHUD.h"
#import "CacheImgs.h"
#import "Api.h"

@interface CIODetalleSerieVC ()
@property (nonatomic, strong) Api *apiRequest;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *caps;
@property (nonatomic, strong) NSMutableArray *seasons;
@property (nonatomic, strong) NSMutableArray *generos;
@property (nonatomic, strong) NSMutableArray *actores;
@end

@implementation CIODetalleSerieVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Detalle";
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.label.text = @"Cargando...";
    
    self.apiRequest = [Api sharedInstance];
    
    self.caps  = [NSMutableArray array];
    self.seasons  = [NSMutableArray array];
    self.generos  = [NSMutableArray array];
    self.actores  = [NSMutableArray array];
    
    self.listCapitulos.delegate = self;
    self.listCapitulos.dataSource = self;
    
    [self loadSerie];
    
}

-(void)loadSerie{

    
    //Carga nombre de serie
    if (![[self.serie objectForKey:@"name"] isEqual:[NSNull null]]){
        self.lblName.text = [self.serie objectForKey:@"name"];
    }
    else{
        self.lblName.text  = @"...";
    }
    
    //Cargar Generos
    [self.apiRequest downloadDetailTvShow:[self.serie objectForKey:@"id"] success:^(BOOL success, id response) {
        
        if (success) {
            //Averiguo generos
            NSArray *genres = [response objectForKey:@"genres"];
            [genres enumerateObjectsUsingBlock: ^(id objeto, NSUInteger indice, BOOL *stop) {
                [self.generos addObject:[objeto objectForKey:@"name"]];
            }];
            
            self.lblGenre.text = [self.generos componentsJoinedByString:@","];
            
            //Numeros de sesiones
            long seasons = [[response objectForKey:@"number_of_seasons"] longValue];
            NSLog(@"%ld", seasons);
            
            for (int i = 1; i <= 6; i++) {
                [self.seasons addObject:[NSString stringWithFormat:@"%d", i]];
            }
            
        
            CGRect myFrame = CGRectMake(5.0f, self.lblEpisodios.frame.origin.y + 26, self.view.bounds.size.width - 5, 40.0f);
            self.mySegmentedControl = [[UISegmentedControl alloc] initWithItems:self.seasons];
            self.mySegmentedControl.frame = myFrame;
            [self.mySegmentedControl addTarget:self
                                        action:@selector(whichSeason:)
                              forControlEvents:UIControlEventValueChanged];
            
            [self.mySegmentedControl setSelectedSegmentIndex:0];
            
            [self.view addSubview:self.mySegmentedControl];
            
        }
        
        //Cargar Actores
        [self.apiRequest downloadCharactersTvShow:[self.serie objectForKey:@"id"] success:^(BOOL success, id response) {
            if (success) {
                //Filtrar actores
                NSArray *actores = [response objectForKey:@"cast"];
                [actores enumerateObjectsUsingBlock: ^(id objeto, NSUInteger indice, BOOL *stop) {
                    [self.actores addObject:[objeto objectForKey:@"name"]];
                }];
            }
            
            //Cargar Capitulo por defecto de episodios
            [self.apiRequest downloadSeasonTvShow:[self.serie objectForKey:@"id"] season:0 success:^(BOOL success, id response) {
                if (success) {
                    //Cargar table con los titulos de los capitulos
                    NSArray *capitulos = [response objectForKey:@"episodes"];
                    [capitulos enumerateObjectsUsingBlock: ^(id objeto, NSUInteger indice, BOOL *stop) {
                        NSString *cap = [NSString stringWithFormat:@"%@. %@", [objeto objectForKey:@"episode_number"], [objeto objectForKey:@"name"]];
                        [self.caps addObject:cap];
                    }];
                    [self.listCapitulos setHidden:NO];
                    [self.listCapitulos reloadData];
                }
                [self.hud setHidden:YES];
                
            }];
            
            self.lblActors.text = [self.actores componentsJoinedByString:@","];
        }];
    }];
    
}

- (void) whichSeason:(UISegmentedControl *)paramSender{
    
    //check if its the same control that triggered the change event
    if ([paramSender isEqual:self.mySegmentedControl]){
        
        //get index position for the selected control
        NSInteger selectedIndex = [paramSender selectedSegmentIndex];
        
        //get the Text for the segmented control that was selected
        NSString *myChoice =
        [paramSender titleForSegmentAtIndex:selectedIndex];
        //let log this info to the console
        NSLog(@"Segment at position %li with %@ text is selected",
              (long)selectedIndex, myChoice);
        
        //Cargar Capitulo por defecto de episodios
        self.hud = [MBProgressHUD showHUDAddedTo:self.listCapitulos animated:YES];
        [self.apiRequest downloadSeasonTvShow:[self.serie objectForKey:@"id"] season:myChoice success:^(BOOL success, id response) {
            if (success) {
                //Cargar table con los titulos de los capitulos
                NSArray *capitulos = [response objectForKey:@"episodes"];
                [self.caps removeAllObjects];
                [capitulos enumerateObjectsUsingBlock: ^(id objeto, NSUInteger indice, BOOL *stop) {
                    NSString *cap = [NSString stringWithFormat:@"%@. %@", [objeto objectForKey:@"episode_number"], [objeto objectForKey:@"name"]];
                    [self.caps addObject:cap];
                }];
                [self.listCapitulos setHidden:NO];
                [self.listCapitulos reloadData];
            }
            [self.hud setHidden:YES];
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.caps.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    NSString *cap = [self.caps objectAtIndex:indexPath.row];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"myCell"];
    }
    
    cell.textLabel.text = cap;
    
    return cell;
}


@end
