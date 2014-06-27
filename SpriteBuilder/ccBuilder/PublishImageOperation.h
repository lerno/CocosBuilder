#import <Foundation/Foundation.h>
#import "PublishBaseOperation.h"
#import "CCBWarnings.h"

@class DateCache;
@class CCBPublisher;
@class FCFormatConverter;
@protocol PublishFileLookupProtocol;

@interface PublishImageOperation : PublishBaseOperation

@property (nonatomic, copy) NSString *srcFilePath;
@property (nonatomic, copy) NSString *dstFilePath;
@property (nonatomic, copy) NSString *outputDir;
@property (nonatomic, copy) NSString *resolution;

@property (nonatomic, strong) NSMutableSet *publishedPNGFiles;
@property (nonatomic, strong) id<PublishFileLookupProtocol> fileLookup;

@property (nonatomic) BOOL isSpriteSheet;
@property (nonatomic) CCBPublisherTargetType targetType;

@property (nonatomic, strong) DateCache *modifiedFileDateCache;

@end