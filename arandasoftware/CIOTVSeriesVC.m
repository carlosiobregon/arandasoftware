//
//  CIOTVSeriesVC.m
//  arandasoftware
//
//  Created by Carlos Obregón on 7/07/16.
//  Copyright © 2016 carlosobregon. All rights reserved.
//

#import "CIOTVSeriesVC.h"
#import "CollectionViewCell.h"
#import "CIODetalleSerieVC.h"
#import "MBProgressHUD.h"
#import "UIScrollView+InfiniteScroll.h"
#import "CustomInfiniteIndicator.h"
#import "Constant.h"
#import "CacheImgs.h"
#import "Api.h"

@interface CIOTVSeriesVC ()
@property (nonatomic, strong) Api *apiRequest;
@property (nonatomic, strong) NSMutableArray *series;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) int page,totalPages, totalResults;
@property (nonatomic, strong) NSString *searchWord;
@end

@implementation CIOTVSeriesVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.label.text = @"Cargando...";
    
    //Cargar datos de inicio
    self.apiRequest = [Api sharedInstance];
    self.series = [NSMutableArray array];
    self.cache = [CacheImgs sharedInstance];
    
    NSDictionary *parameters = @{@"api_key":@"2ea5adc47456e674399d947d032e74e5"};
    
    [self.apiRequest downloadTvShows:parameters success:^(BOOL success, id response) {
        if (success) {
            NSLog(@"%@",response);
            
            NSArray *results = [response objectForKey:@"results"];
            
            
            [results enumerateObjectsUsingBlock: ^(id objeto, NSUInteger indice, BOOL *stop) {
                [self.series addObject:objeto];
            }];
            [self.seriesCV reloadData];
            [self.hud hideAnimated:YES];
            [self.seriesCV setHidden:NO];
        }
        else{
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Alerta"
                                                message:@"Fallo la carga de series, verifique su conxion a internet y vuelva a intentarlo"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *accion =
            [UIAlertAction actionWithTitle:@"Aceptar"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
            
            [alert addAction:accion];
            
            self.hud.hidden = YES;
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    UINib *nib = [UINib nibWithNibName:@"CollectionViewCell" bundle:nil];
    [self.seriesCV registerNib:nib forCellWithReuseIdentifier:[CollectionViewCell cellId]];
    
    self.seriesCV.delegate = self;
    self.seriesCV.dataSource = self;
    
    
    /////
    // Create custom indicator
    CGRect indicatorRect;
    
#if TARGET_OS_TV
    indicatorRect = CGRectMake(0, 0, 64, 64);
#else
    indicatorRect = CGRectMake(0, 0, 24, 24);
#endif
    
    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:indicatorRect];
    
    // Set custom indicator
    self.seriesCV.infiniteScrollIndicatorView = indicator;
    
    // Set custom indicator margin
    self.seriesCV.infiniteScrollIndicatorMargin = 40;
    
    // Add infinite scroll handler
    [self addInfiniteScrollHandler];
    
}

#pragma mark - Infinity Scroll
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    // invalidate layout on rotation
    [self.seriesCV.collectionViewLayout invalidateLayout];
}
- (void)addInfiniteScrollHandler{
    
    [self.seriesCV addInfiniteScrollWithHandler:^(UICollectionView *collectionView) {
        //descargar nuevos datos
        self.page++;
        if (self.page < self.totalPages && self.searchWord != nil) {
            [self.apiRequest downloadSearchTvShows:self.searchWord page:[NSString stringWithFormat:@"%d",self.page] success:^(BOOL success, id response) {
                if (success) {
                    self.page = [[response objectForKey:@"page"] intValue];
                    self.totalPages = [[response objectForKey:@"total_pages"] intValue];
                    int totalResults = [[response objectForKey:@"total_results"] intValue];
                    NSArray *results = [response objectForKey:@"results"];
                    
                    
                    if (totalResults > 0) {
                        
                        
                        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                        NSInteger index = self.series.count;
                        
                        for(NSDictionary *dic in results) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index++ inSection:0];
                            
                            [self.series addObject:dic];
                            [indexPaths addObject:indexPath];
                        }
                        
                        [self.seriesCV performBatchUpdates:^{
                            [self.seriesCV insertItemsAtIndexPaths:indexPaths];
                        } completion:^(__unused BOOL finished) {
                            [collectionView finishInfiniteScroll];
                        }];
                        
                    }
                }
            }];
        }
        else{
            [collectionView finishInfiniteScroll];
        }
    }];
    
    
    
}

#pragma mark - Busqueda API
- (IBAction)buscarSerie:(id)sender {
    
    if (![self.tfBusqueda.text isEqualToString:@""]) {
        
        NSString *textSearch =
        [self.tfBusqueda.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        self.searchWord = textSearch;
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.label.text = @"Buscando...";
        
        //Realizar peticion de busqueda al API
        [self.apiRequest downloadSearchTvShows:textSearch success:^(BOOL success, id response) {
            if (success) {
                //Descarga Exitosa
                NSLog(@"%@",response);
                
                self.page = [[response objectForKey:@"page"] intValue];
                self.totalPages = [[response objectForKey:@"total_pages"] intValue];
                int totalResults = [[response objectForKey:@"total_results"] intValue];
                NSArray *results = [response objectForKey:@"results"];
                
                
                if (totalResults > 0) {
                    [self.series removeAllObjects];
                    
                    [results enumerateObjectsUsingBlock: ^(id objeto, NSUInteger indice, BOOL *stop) {
                        [self.series addObject:objeto];
                    }];
                    [self.seriesCV reloadData];
                    [self.hud hideAnimated:YES];
                    [self.seriesCV setHidden:NO];
                }
                else{
                    UIAlertController *alert =
                    [UIAlertController alertControllerWithTitle:@"Alerta"
                                                        message:@"No se encontraron series por esta busqueda"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *accion =
                    [UIAlertAction actionWithTitle:@"Aceptar"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                           }];
                    
                    [alert addAction:accion];
                    
                    self.hud.hidden = YES;
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }
        }];
        //Actualizar SeriesCV
    }
    else{
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Alerta"
                                            message:@"Debe ingresar un parametro de busqueda"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *accion =
        [UIAlertAction actionWithTitle:@"Aceptar"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
        
        [alert addAction:accion];
        
        self.hud.hidden = YES;
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
    
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.series.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewCell cellId]
                                              forIndexPath:indexPath];
    
    
    NSDictionary *serie = [self.series objectAtIndex:indexPath.row];
    
    
    if (![[serie objectForKey:@"name"] isEqual:[NSNull null]]){
        cell.laName.text = [serie objectForKey:@"name"];
    }
    else{
        cell.laName.text = @"...";
    }
    [cell.laName sizeToFit];
    
    
    
    if (![[serie objectForKey:@"poster_path"] isEqual:[NSNull null]]){
        NSURL *urlSerie = [NSURL URLWithString:[serie objectForKey:@"poster_path"]];
        UIImage *imgSerie = [self.cache objectForKey:urlSerie];
        
        if (imgSerie) {
            cell.imgSerie.image = imgSerie;
        }
        else{
            [cell.activityLoad startAnimating];
            [self.apiRequest downloadPhotoFromURL:urlSerie completion:^(NSURL *URL, UIImage *image) {
                if (image) {
                    cell.imgSerie.image = image;
                }
                [cell.activityLoad stopAnimating];
            }];
        }
    }
   
    
    return cell;
    
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *serie = [self.series objectAtIndex:indexPath.row];
    
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:DEVICE_IPHONE]) {
        CIODetalleSerieVC *detalleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detalleSerieVC"];
        detalleVC.serie = serie;
        
        [self.navigationController pushViewController:detalleVC animated:YES];
    }
    else {
        CIODetalleSerieVC *detalleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"iPadDetalleSerieVC"];
        detalleVC.serie = serie;
        
        [self.navigationController pushViewController:detalleVC animated:YES];
    }
    
    
    
    
}

#pragma mark - Warning Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
