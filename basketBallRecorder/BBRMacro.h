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
//#define BAR_HEIGHT 33               // for iphones
//#define BAR_HEIGHT 64

#define NO_TABLEVIEW_TAG -1
#define PLAYER_ON_FLOOR_TABLEVIEW_TAG -2
#define PLAYER_GRADE_TABLEVIEW_TAG -3
#define PLAYER_GRADE_TABLECELL_HEIGHT 30
#define BACKGROUND_IMAGEVIEW_TAG -4
#define DETAIL_TABLE_VIEW -5

#define KEY_FOR_LAST_RECORD_QUARTER @"LastRecordQuarter"

#define TITLE_FOR_PLAYER_NO_TABLEVIEW @"球員";

//Segue ID
#define SEGUE_ID_FOR_DEFENSE @"showDefenseController"
#define SEGUE_ID_FOR_OFFENSE @"showOffenseController"
#define SEGUE_ID_FOR_BOX_SCORE @"showBoxScoreController"

//Key using in tmpPlistDic
#define OFFENSE_TYPE_DATA @"Offense"
#define DEFENSE_TYPE_DATA @"Defense"
#define BOX_RECORD_TYPE_DATA @"Box Record"
#define KEY_FOR_DATA_TYPE @"Type"
#define KEY_FOR_TIMELINE @"timeLine"
#define KEY_FOR_TIME @"time"
#define KEY_FOR_GRADE @"Grade"
#define KEY_FOR_NAME @"Name"
#define KEY_FOR_OPPONENT_NAME @"OpponentName"
#define KEY_FOR_PLAYER_NO_SET @"PlayerNoSet"
#define KEY_FOR_ON_FLOOR_PLAYER_DATA @"PlayersOnFloorData"
#define KEY_FOR_DATE @"Date"

//Offense
#define KEY_FOR_FASTBREAK @"Fastbreak"
#define KEY_FOR_ISOLATION @"Isolation"
#define KEY_FOR_OFF_SCREEN @"OffScreen"
#define KEY_FOR_CUT @"Cut"
#define KEY_FOR_DK @"DK"
#define KEY_FOR_OTHERS @"Others"
#define KEY_FOR_PNR @"PNR"
#define KEY_FOR_SECOND @"Second"
#define KEY_FOR_PU @"PU"
#define KEY_FOR_TURNOVER @"turnover"
#define KEY_FOR_TOTAL @"Total"

#define TITLE_FOR_DRIVE @"切入上籃(D)"
#define TITLE_FOR_PULL_UP @"帶一步投籃(P)"
#define TITLE_FOR_SPOT_UP @"原地投籃(S)"
#define TITLE_FOR_BP @"持球者帶一步跳投(BP)"
#define TITLE_FOR_BD @"持球者切入(BD)"
#define TITLE_FOR_MR @"掩護者Roll in(MR)"
#define TITLE_FOR_MPP @"掩護者帶一步跳投(MPP)"
#define TITLE_FOR_MPD @"掩護者持球切入(MPD)"
#define TITLE_FOR_MPS @"掩護者外翻原地跳投(MPS)"
#define TITLE_FOR_PUT_BACK @"補籃(PB)"
#define TITLE_FOR_SF @"要位第一拍出手(SF)"
#define TITLE_FOR_LP @"低位單打(LP)"

#define KEY_FOR_DRIVE @"D"
#define KEY_FOR_PULL_UP @"P"
#define KEY_FOR_SPOT_UP @"S"
#define KEY_FOR_BP @"BP"
#define KEY_FOR_BD @"BD"
#define KEY_FOR_MR @"MR"
#define KEY_FOR_MPP @"MPP"
#define KEY_FOR_MPD @"MPD"
#define KEY_FOR_MPS @"MPS"
#define KEY_FOR_PUT_BACK @"PB"
#define KEY_FOR_SF @"SF"
#define KEY_FOR_LP @"LP"

#define KEY_FOR_STOLEN @"Stolen"
#define KEY_FOR_BAD_PASS @"Bad Pass"
#define KEY_FOR_CHARGING @"Charging"
#define KEY_FOR_DROP @"Drop"
#define KEY_FOR_3_SENCOND @"Three Second"
#define KEY_FOR_TRAVELING @"Traveling"
#define KEY_FOR_TEAM @"Team"

#define KEY_FOR_ATTEMPT_COUNT @"attempCount"
#define KEY_FOR_MADE_COUNT @"madeCount"
#define KEY_FOR_FOUL_COUNT @"foulCount"
#define KEY_FOR_SCORE_GET @"scoreGet"
#define KEY_FOR_HOLD_BALL_COUNT @"holdBallCount"

#define KEY_FOR_TOTAL_MADE_COUNT @"totalMadeCount"
#define KEY_FOR_TOTAL_ATTEMPT_COUNT @"totalAttemptCount"
#define KEY_FOR_TOTAL_FOUL_COUNT @"totalFoulCount"
#define KEY_FOR_TOTAL_TURNOVER_COUNT @"totalTurnoverCount"
#define KEY_FOR_TOTAL_SCORE_GET @"totalScoreGet"
#define KEY_FOR_TOTAL_TIME_ON_FLOOR @"timeOnFloor"

#define KEY_FOR_TIME_WHEN_GO_ON_FLOOR @"timeWhenGoOnFloor"
#define KEY_FOR_INDEX_IN_PPP_TABLEVIEW @"indexInPPPTableview"

#define KEY_FOR_DEFENSE_GRADE @"defenseGrade"
#define KEY_FOR_DEFLECTION_DEFENSE_GRADE @"deflection"
#define KEY_FOR_GOOD_DEFENSE_GRADE @"good"
#define KEY_FOR_BAD_DEFENSE_GRADE @"bad"
#define KEY_FOR_TOTAL_COUNT @"total"

//Key for timeLine event
#define KEY_FOR_PLAYER_ON_FLOOR @"playerOnFloor"
#define KEY_FOR_TIME_LINE_DATA @"timeLineData"
#define KEY_FOR_PLAYER_NO @"PlayerNo"
#define KEY_FOR_ATTACK_WAY @"AttackWay"
#define KEY_FOR_DETAIL @"Detail"
#define KEY_FOR_RESULT @"Result"
#define KEY_FOR_PTS @"Pts"
#define KEY_FOR_BONUS @"Bonus"
#define KEY_FOR_TYPE @"type"

#define SIGNAL_FOR_EXCHANGE @"Exchange"
#define SIGNAL_FOR_NON_EXCHANGE @"NoneExchange"
#define SIGNAL_FOR_FOUL @"Foul"
#define SIGNAL_FOR_AND_ONE @"And 1"
#define SIGNAL_FOR_ATTEMPT @"Attempt"
#define SIGNAL_FOR_MADE @"Made"
#define SIGNAL_FOR_TURNOVER @"TO"

//Box Score
#define KEY_FOR_2_PTS @"2PTS"
#define KEY_FOR_3_PTS @"3PTS"
#define KEY_FOR_FREE_THROW @"Free Throw"
#define KEY_FOR_OR @"OR"
#define KEY_FOR_DR @"DR"
#define KEY_FOR_ASSIST @"Assist"
#define KEY_FOR_STEAL @"Steal"
#define KEY_FOR_BLOCK @"Block"
#define KEY_FOR_TO @"Turnover"
#define KEY_FOR_FOUL @"Foul"

//Dropbox
#define NAME_OF_THE_FINAL_XLSX_FILE @"PPP數據"
#define NAME_OF_THE_SHOT_CHART_XLSX_FILE @"Shot Chart"
#define NAME_OF_THE_ZONE_GRADE_XLSX_FILE @"投籃分佈圖"

#define END -1
#define QUARTER_NO_FOR_ENTIRE_GAME 0



#endif /* BBRMacro_h */
