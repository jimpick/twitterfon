#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"
#import "ImageDownloader.h"

@interface ProfileImage : NSObject
{
  	NSObject*           delegate;
    User*               user;
	UIImage*            image;
    BOOL                needUpdate;
    sqlite3*            database;
    ImageDownloader*    downloader;
}

@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, assign) User* user;

- (ProfileImage*)initWithUser:(User*)user delegate:(id)aDelegate;

@end
