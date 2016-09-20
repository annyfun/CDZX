#import <sqlite3.h>
#import "Statement.h"

#define MAIN_DATABASE_NAME @"Base.db"

//
// Interface for Database connector
//
@interface DBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force;
+ (void)deleteMessageCache;

+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)beginTransaction;
+ (void)commitTransaction;

+ (Statement*)statementWithQuery:(const char*)sql;

+ (void)alert;

@end