//
//  Api.h
//  Neptune
//  Created by Leonardo Rodriguez on 1/5/16.
//

#import <AFNetworking/AFNetworking.h>

typedef void(^ResponseBlock)(BOOL success,id response);

@interface Api : AFHTTPRequestOperationManager

+(instancetype)sharedInstance;

-(void)downloadTvShows:(NSDictionary *)parameters success:(ResponseBlock)success;
-(void)downloadSearchTvShows:(NSString *)textSearch success:(ResponseBlock)success;
-(void)downloadDetailTvShow:(NSString *)idSerie success:(ResponseBlock)success;
-(void)downloadCharactersTvShow:(NSString *)idSerie success:(ResponseBlock)success;
-(void)downloadSeasonTvShow:(NSString *)idSerie season:(NSString *)season success:(ResponseBlock)success;
-(void)downloadPhotoFromURL:(NSURL*)URL completion:(void(^)(NSURL *URL, UIImage *image))completion;


@end
