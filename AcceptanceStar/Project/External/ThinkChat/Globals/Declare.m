//
//  File.c
//  BusinessMate
//
//  Created by kiwi on 6/14/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import "Declare.h"

Location LocationMake(double la, double ln) {
    Location res;
    res.lat = la;
    res.lng = ln;
    return res;
}