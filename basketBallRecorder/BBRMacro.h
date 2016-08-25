//
//  BBRMacro.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/8/25.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#ifndef BBRMacro_h
#define BBRMacro_h


#define TITLE_CELL_HEIGHT 30
#define CELL_HEIGHT 40
#define CELL_WIDTH 40

#define BACKGROUND_WIDTH 373
#define BACKGROUND_HEIGHT 245
#define IMAGE_SCALE 0.465
#define RECORD_LABEL_HEIGHT 23
#define SIDE_PADDING_RATE 0.25      //for zone 6, 10
#define TOP_PADDING_RATE1 0.1       //for zone 1, 2, 4, 5, 7, 9, 11
#define TOP_PADDING_RATE2 0.3       //for zone 3
#define TOP_PADDING_RATE3 0.6       //for zone 6, 10
#define TOP_PADDING_RATE4 0         //for zone 8
#define NO_TABLEVIEW_TAG -1
#define PLAYER_ON_FLOOR_TABLEVIEW_TAG -2
#define PLAYER_GRADE_TABLEVIEW_TAG -3
#define PLAYER_GRADE_TABLECELL_HEIGHT 30
#define BACKGROUND_IMAGEVIEW_TAG -4
#define BAR_HEIGHT 33

#define KEY_FOR_ATTEMPT_COUNT @"attempCount"
#define KEY_FOR_MADE_COUNT @"madeCount"
#define KEY_FOR_FOUL_COUNT @"foulCount"
#define KEY_FOR_TURNOVER_COUNT @"turnoverCount"
#define KEY_FOR_SCORE_GET @"scoreGet"

#define KEY_FOR_TOTAL_MADE_COUNT @"totalMadeCount"
#define KEY_FOR_TOTAL_ATTEMPT_COUNT @"totalAttemptCount"
#define KEY_FOR_TOTAL_FOUL_COUNT @"totalFoulCount"
#define KEY_FOR_TOTAL_TURNOVER_COUNT @"totalTurnoverCount"
#define KEY_FOR_TOTAL_SCORE_GET @"totalScoreGet"
#define KEY_FOR_TOTAL_TIME_ON_FLOOR @"timeOnFloor"

#define KEY_FOR_TIME_WHEN_GO_ON_FLOOR @"timeWhenGoOnFloor"
#define KEY_FOR_INDEX_IN_PPP_TABLEVIEW @"indexInPPPTableview"
#define KEY_FOR_TIME @"time"

#define KEY_FOR_DEFENSE_GRADE @"defenseGrade"
#define KEY_FOR_DEFLECTION_DEFENSE_GRADE @"deflection"
#define KEY_FOR_GOOD_DEFENSE_GRADE @"good"
#define KEY_FOR_BAD_DEFENSE_GRADE @"bad"
#define KEY_FOR_TOTAL_COUNT @"total"

#define END -1
#define QUARTER_NO_FOR_ENTIRE_GAME 0



#endif /* BBRMacro_h */
