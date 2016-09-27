#import "TCDBConnection.h"
#import "TCStatement.h"

#define TC_DB_V_S @"TC_DB_Version_Store"

static sqlite3*             theDatabase = nil;


@implementation TCDBConnection

+ (sqlite3*)openDatabase:(NSString*)dbFilename
{
    sqlite3* instance = NULL;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(instance);
        // TCSDKLog(@"Failed to open database. (%s)", sqlite3_errmsg(instance));
        return nil;
    }        
    return instance;
}

+(void)dbVersionControl
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * version_old = [defaults objectForKey:TC_DB_V_S];
    NSString * version_new = [NSString stringWithFormat:@"%@", TC_DB_Version];
    // TCSDKLog(@"dbVersionControl before: %@ after: %@",version_old,version_new);
    
    if ( version_old == nil || ![version_new isEqualToString:version_old]) {
        // TCSDKLog(@"del db file!!!");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
        if ([fileManager fileExistsAtPath:writableDBPath]) {
            [fileManager removeItemAtPath:writableDBPath error:&error];
            if (error) {
                // TCSDKLog(@"Can not delete DB file with error : %@", [error localizedFailureReason]);
            }
        }

        [defaults setValue:version_new forKey:TC_DB_V_S];
        [defaults synchronize];
    }
}

+ (sqlite3*)getSharedDatabase
{
    [TCDBConnection dbVersionControl];
    if (theDatabase == nil) {
        theDatabase = [self openDatabase:MAIN_DATABASE_NAME];
        if (theDatabase == nil) {
            [TCDBConnection createEditableCopyOfDatabaseIfNeeded:true];
        }
    }
    
    return theDatabase;
}

//
// delete caches
//
const char *delete_message_cache_tc_sql = 
"BEGIN;"
"DELETE FROM timeline;"
"DELETE FROM favorites;"
"DELETE FROM drafts;"
"DELETE FROM userComments;"
"DELETE FROM comments;"
"DELETE FROM mentions;"
"DELETE FROM statuses;"
"DELETE FROM directMessages;"
"DELETE FROM users;"
"COMMIT;"
"VACUUM;";

+ (void)deleteMessageCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, delete_message_cache_tc_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        // TCSDKLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

//
// cleanup and optimize
//
const char *cleanup_tc_sql =
"BEGIN;"
"DELETE FROM userComments WHERE commentId <= (SELECT commentId FROM userComments ORDER BY commentId DESC LIMIT 1 OFFSET 1000);"
"DELETE FROM comments WHERE commentId NOT IN (SELECT commentId FROM userComments);"
"DELETE FROM mentions WHERE statusId <= (SELECT statusId FROM mentions ORDER BY statusId DESC LIMIT 1 OFFSET 4000);"
"DELETE FROM timeline WHERE statusId <= (SELECT statusId FROM timeline ORDER BY statusId DESC LIMIT 1 OFFSET 4000);"
"DELETE FROM statuses WHERE statusId NOT IN (SELECT statusId FROM timeline) and statusId NOT IN (SELECT statusId FROM favorites) and statusId NOT IN (SELECT statusId FROM mentions) and statusId NOT IN (SELECT statusId FROM comments);"
"COMMIT";


const char *optimize_tc_sql = "VACUUM; ANALYZE";

+ (void)closeDatabase
{
    char *errmsg;
    if (theDatabase) {
		/*
        if (sqlite3_exec(theDatabase, cleanup_tc_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            // ignore error
            // TCSDKLog(@"Error: failed to cleanup chache (%s)", errmsg);
        }
		 */
        
      	NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        // TCSDKLog(@"launchCount %ld", (long)launchCount);
        if (launchCount-- <= 0) {
            // TCSDKLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_tc_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                // TCSDKLog(@"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = 50;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
        
    if (force) {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    
    // No exists any database file. Create new one.
    //
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

+ (void)beginTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "BEGIN", NULL, NULL, &errmsg);     
}

+ (void)commitTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "COMMIT", NULL, NULL, &errmsg);     
}

+ (TCStatement*)statementWithQuery:(const char *)sql
{
    TCStatement* stmt = [TCStatement statementWithDB:theDatabase query:sql];
    return stmt;
}

+ (void)alert
{
//    NSString *sqlite3err = [NSString stringWithUTF8String:sqlite3_errmsg(theDatabase)];
    // TCSDKLog(@"%@",sqlite3err);
}

@end
