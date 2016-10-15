//
//  ColorHelper.h
//  BusinessMate
//
//  Created by kiwi on 5/9/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#ifndef Custom_ColorHelper_h
#define Custom_ColorHelper_h

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 \
alpha:(a)]

#define kColorClear [UIColor clearColor]
#define kColorWhite [UIColor whiteColor]

#define kColorTitleBlack        RGBCOLOR( 16, 16, 16)
#define kColorTitleGray         RGBCOLOR(130,130,130)
#define kColorTitleLightGray    RGBCOLOR(167,167,167)
#define kColorTitleBlue         RGBCOLOR(  0,123,253)
#define kColorTitleRed          RGBCOLOR(223, 51, 24)

#define kColorBtnBkgBlue        RGBCOLOR(  2,159,240)
#define kColorBtnBkgRed         RGBCOLOR(220, 48, 48)
#define kColorBtnBkgGreen       RGBCOLOR(128,213, 94)

#define kColorViewBkg   RGBCOLOR(239, 239, 239)

#define kColorSearchBkg RGBCOLOR(217, 217, 217)

#define kColorNavTitle  kColorTitleBlack
#define kColorNavBkg    RGBCOLOR(248, 248, 248)

#define kColorTabTitleD kColorTitleBlue
#define kColorTabTitleN kColorTitleGray
#define kColorTabBkg    RGBCOLOR(248, 248, 248)

#define kColorCellBkgN  [UIColor whiteColor]
#define kColorCellBkgD  RGBACOLOR(0, 123, 253, 0.5)
#define kColorTitle     kColorTitleBlack
#define kColorDetail    kColorTitleGray

#define kColorTitleCancel   kColorTitleBlack

#endif
