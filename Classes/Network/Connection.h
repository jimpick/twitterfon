//
//  Connection.h
//  TwitterFon
//
//  Created by kaz on 7/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

@interface Connection : NSObject
{
	NSObject*           delegate;
	NSURLConnection*    conn;
	NSMutableData*      buf;
}

- (id)initWithDelegate:(NSObject*)delegate;
- (void)get:(NSString*)URL;
- (void)post;

@end
