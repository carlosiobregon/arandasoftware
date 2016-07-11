//
//  Api.m
//  arandasoftware
//  Created by Carlos Obregon on 09/06/2016

#import "Api.h"
#import "CacheImgs.h"


NSString *const urlBase = @"http://api.themoviedb.org/";
NSString *const urlBaseResources = @"http://image.tmdb.org/t/p/w500";
NSString *const apiKey = @"api_key=2ea5adc47456e674399d947d032e74e5";

@implementation Api

+(instancetype)sharedInstance {
    static dispatch_once_t onceQueue;
    static Api *__sharedInstance = nil;
    dispatch_once(&onceQueue, ^{
        __sharedInstance = [[self alloc] init];
    });
    
    return __sharedInstance;
    
}


-(void)downloadTvShows:(NSDictionary *)parameters success:(ResponseBlock)success{
    
    NSString *endpoint = [NSString stringWithFormat:@"%@%@%@",urlBase,@"3/discover/tv?", apiKey];
    
    [self getRequest:endpoint succes:success];
    //[self postRequest:endpoint parameters:parameters success:success];
}

- (void)downloadPhotoFromURL:(NSURL *)URL completion:(void(^)(NSURL *URL, UIImage *image))completion {
    static dispatch_queue_t downloadQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadQueue = dispatch_queue_create("ru.codeispoetry.downloadQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    NSString *endpoint = [NSString stringWithFormat:@"%@%@",urlBaseResources, URL];
    NSURL *urlSerie = [NSURL URLWithString:endpoint];
    
    dispatch_async(downloadQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:urlSerie];
        UIImage *image = [UIImage imageWithData:data];
        
        if(image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSCache *cache = [CacheImgs sharedInstance];
                [cache setObject:image forKey:URL];
                
                if(completion) {
                    completion(URL, image);
                }
            });
        }
    });
}

-(void)downloadSearchTvShows:(NSString *)textSearch success:(ResponseBlock)success{
    NSString *endpoint = [NSString stringWithFormat:@"%@%@query=%@&%@",urlBase,@"3/search/tv?",textSearch, apiKey];
    
    [self getRequest:endpoint succes:success];
}
-(void)downloadDetailTvShow:(NSString *)idSerie success:(ResponseBlock)success{
    //http://api.themoviedb.org/3/tv/32125?api_key=2ea5adc47456e674399d947d032e74e5
    NSString *endpoint = [NSString stringWithFormat:@"%@%@%@?%@",urlBase,@"3/tv/",idSerie, apiKey];
    
    [self getRequest:endpoint succes:success];
}

-(void)downloadCharactersTvShow:(NSString *)idSerie success:(ResponseBlock)success{
    //http://api.themoviedb.org/3/tv/38585/credits?api_key=2ea5adc47456e674399d947d032e74e5
    NSString *endpoint = [NSString stringWithFormat:@"%@%@%@/credits?%@",urlBase,@"3/tv/",idSerie, apiKey];
    
    [self getRequest:endpoint succes:success];
}

-(void)downloadSeasonTvShow:(NSString *)idSerie season:(NSString *)season success:(ResponseBlock)success{
    //http://api.themoviedb.org/3/tv/32125/season/0?api_key=2ea5adc47456e674399d947d032e74e5
    NSString *endpoint = [NSString stringWithFormat:@"%@%@%@/season/%@?%@",urlBase,@"3/tv/",idSerie, season,apiKey];
    
    [self getRequest:endpoint succes:success];
}


-(void)getRequest:(NSString *)endpoint succes:(ResponseBlock)success{
    //self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [self GET:endpoint parameters:nil
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if ([responseObject isKindOfClass:[NSDictionary class]]){
               success(YES,responseObject);
           }
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           success(NO,error);
       }];

}

-(void)postRequest:(NSString *)endpoint parameters:(NSDictionary *)parameters success:(ResponseBlock)success {
    
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [self POST:endpoint parameters:parameters
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           //if ([responseObject isKindOfClass:[NSDictionary class]]){
               success(YES,responseObject);
           //}
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           success(NO,error);
       }];
}


@end
