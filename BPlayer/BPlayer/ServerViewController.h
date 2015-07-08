
#import <UIKit/UIKit.h>
#import "WithTableViewController.h"

#import <MediaServerBrowserService/MediaServerBrowserService.h>
#import <MediaServerBrowserService/MediaServerCrawler.h>


#import "TestTableViewController.h"

@interface ServerViewController : WithTableViewController


@property (nonatomic, retain) NSArray* dataSource;
@property (nonatomic, retain) NSArray* renderers;
@property (nonatomic,retain) NSMutableDictionary* dmsArr;
@property (nonatomic,retain)NSIndexPath *lastIndexPath;

- (id)initWithDevices:(NSMutableDictionary*)sender frame:(CGRect)frame;
@end
