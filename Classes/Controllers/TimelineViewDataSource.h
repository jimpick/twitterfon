#import <UIKit/UIKit.h>
#import "ImageStore.h"
#import "Timeline.h"
#import "TwitterClient.h"
#import "UserTimelineController.h"

@interface TimelineViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    UITableViewController*  controller;
	Timeline*               timeline;
    UserTimelineController* userTimeline;
    ImageStore*             imageStore;
    int                     tag;
    NSString*               query;
    float                   latitude, longitude;

    int                     insertPosition;
    int                     since_id;
}

@property(nonatomic, assign) Timeline* timeline;
@property(nonatomic, copy) NSString* query;

- (id)initWithController:(UITableViewController*)controller tag:(int)tag;

- (void)getTimeline:(MessageType)type page:(int)page insertAt:(int)row;
- (void)search;
- (void)search:(NSString*)query;
- (void)geocode:(float)latitude longitude:(float)longitude;

- (void)removeMessage:(Message*)message;
- (void)removeAllMessages;
- (void)updateFavorite:(Message*)message;

@end
