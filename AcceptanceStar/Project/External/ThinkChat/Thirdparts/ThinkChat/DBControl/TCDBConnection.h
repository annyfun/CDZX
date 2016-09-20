#import <sqlite3.h>
#import "TCStatement.h"

#define MAIN_DATABASE_NAME @"ThinkChat.db"

//
// Interface for Database connector
//
@interface TCDBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force;
+ (void)deleteMessageCache;

+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)beginTransaction;
+ (void)commitTransaction;

+ (TCStatement*)statementWithQuery:(const char*)sql;

+ (void)alert;

@end