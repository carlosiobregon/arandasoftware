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
#import "Constant.h"
#import "Api.h"

@interface CIODetalleSerieVC ()
@property (nonatomic, strong) Api *apiRequest;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *caps;
@property (nonatomic, strong) NSMutableArray *seasons;
@property (nonatomic, strong) NSMutableArray *generos;
@property (nonatomic, strong) NSMutableArray *actores;
@property (nonatomic, strong) NSCache *cache;
@end

@implementation CIODetalleSerieVC
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Detalle";
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //self.hud.label.text = @"Cargando...";
    
    self.apiRequest = [Api sharedInstance];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:DEVICE_IPAD]) {
        if (![[self.serie objectForKey:@"poster_path"] isEqual:[NSNull null]]){
            NSURL *urlSerie = [NSURL URLWithString:[self.serie objectForKey:@"poster_path"]];
            UIImage *imgSerie = [self.cache objectForKey:urlSerie];
            
            if (imgSerie) {
                self.imgSerie.image = imgSerie;
            }
            else{
                [self.activityLoad startAnimating];
                [self.apiRequest downloadPhotoFromURL:urlSerie completion:^(NSURL *URL, UIImage *image) {
                    if (image) {
                        self.imgSerie.image = image;
                    }
                    [self.activityLoad stopAnimating];
                }];
            }
        }
    }

    self.cache = [CacheImgs sharedInstance];
    
    self.caps  = [NSMutableArray array];
    self.seasons  = [NSMutableArray array];
    self.generos  = [NSMutableArray array];
    self.actores  = [NSMutableArray array];
    
    self.listCapitulos.delegate = self;
    self.listCapitulos.dataSource = self;
    
    [self loadSerie];
    
}

#pragma mark - LoadData
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
            
            for (int i = 1; i <= seasons; i++) {
                [self.seasons addObject:[NSString stringWithFormat:@"%d", i]];
            }
            
            CGRect myFrame;
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:DEVICE_IPAD]) {
                 myFrame = CGRectMake(self.listCapitulos.frame.origin.x, self.listCapitulos.frame.origin.y - 50, self.listCapitulos.frame.size.width, 40.0f);
            }
            else{
                 myFrame = CGRectMake(10.0f, self.lblEpisodios.frame.origin.y + 26, self.view.bounds.size.width - 15.0f, 40.0f);
            }
            
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
            [self.apiRequest downloadSeasonTvShow:[self.serie objectForKey:@"id"] season:@"1" success:^(BOOL success, id response) {
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

#pragma mark - Actions
-(void)whichSeason:(UISegmentedControl *)paramSender{
    
    //Escoger temporada
    if ([paramSender isEqual:self.mySegmentedControl]){
        
        //obtener posicion
        NSInteger selectedIndex = [paramSender selectedSegmentIndex];
        
        //obtener texto del boton
        NSString *myChoice =
        [paramSender titleForSegmentAtIndex:selectedIndex];
        
        NSLog(@"Segment at position %li with %@ text is selected",
              (long)selectedIndex, myChoice);
        
        //Cargar Capitulo
        self.hud = [MBProgressHUD showHUDAddedTo:self.listCapitulos animated:YES];
        [self.apiRequest downloadSeasonTvShow:[self.serie objectForKey:@"id"] season:myChoice success:^(BOOL success, id response) {
            if (success) {
                //Cargar tabla con los titulos de los capitulos
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

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
