#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"

@interface ProfileImage : NSObject
{
  	NSObject*           delegate;
    User*               user;
	UIImage*            image;
    BOOL                needUpdate;
    sqlite3*            database;
}

@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, assign) User* user;

- (ProfileImage*)initWithUser:(User*)user delegate:(id)aDelegate;

@end
