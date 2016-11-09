//
//  BBRMacro.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/8/25.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#ifndef BBRMacro_h
#define BBRMacro_h

#define Dropbox
#define BIJI

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
#define SHOT_MODE_TABLE_VIEW -5

#define KEY_FOR_LAST_RECORD_QUARTER @"LastRecordQuarter"

#define TITLE_FOR_PLAYER_NO_TABLEVIEW @"球員"
#define NAME_OF_NTU_MALE_BASKETBALL @"台大校男籃"

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
#define KEY_FOR_MY_TEAM_NAME @"myTeam"
#define KEY_FOR_OPPONENT_NAME @"OpponentName"
#define KEY_FOR_PLAYER_NO_SET @"PlayerNoSet"
#define KEY_FOR_ON_FLOOR_PLAYER_DATA @"PlayersOnFloorData"
#define KEY_FOR_DATE @"Date"

//Offense - OffMode
#define TITLE_FOR_FASTBREAK @"快攻(F)"
#define KEY_FOR_FASTBREAK @"fb"
#define TITLE_FOR_ISOLATION @"拉開單打(I)"
#define KEY_FOR_ISOLATION @"isolation"
#define TITLE_FOR_OFF_SCREEN @"無球掩護(OS)"
#define KEY_FOR_OFF_SCREEN @"os"
#define TITLE_FOR_CUT @"空切(C)"
#define KEY_FOR_CUT @"cut"
#define TITLE_FOR_DK @"切傳(DK)"
#define KEY_FOR_DK @"dk"
#define TITLE_FOR_OTHERS @"其他(O)"
#define KEY_FOR_OTHERS @"others"
#define TITLE_FOR_PNR @"高位擋拆(PNR)"
#define KEY_FOR_PNR @"pnr"
#define TITLE_FOR_SECOND @"二波進攻(2)"
#define KEY_FOR_SECOND @"sb"
#define TITLE_FOR_PU @"低位(PU)"
#define KEY_FOR_PU @"pu"
#define TITLE_FOR_HP @"高位(HP)"
#define KEY_FOR_HP @"hp"
#define TITLE_FOR_TURNOVER @"失誤(TO)"
#define KEY_FOR_TURNOVER @"turnover"

#define TITLE_FOR_BONUS @"罰球"
#define TITLE_FOR_TIME @"上場時間"
#define KEY_FOR_TOTAL @"Total"

// Offense - ShotMode
#define TITLE_FOR_DRIVE @"切入上籃(D)"
#define KEY_FOR_DRIVE @"drive"
#define TITLE_FOR_PULL_UP @"帶一步投籃(P)"
#define KEY_FOR_PULL_UP @"pu"
#define TITLE_FOR_SPOT_UP @"原地投籃(S)"
#define KEY_FOR_SPOT_UP @"su"
#define TITLE_FOR_HL @"高低配合(HL)"
#define KEY_FOR_HL @"hl"
#define TITLE_FOR_BP @"持球者帶一步跳投(BP)"
#define KEY_FOR_BP @"bp"
#define TITLE_FOR_BD @"持球者切入(BD)"
#define KEY_FOR_BD @"bd"
#define TITLE_FOR_MR @"掩護者Roll in(MR)"
#define KEY_FOR_MR @"mr"
#define TITLE_FOR_MPP @"掩護者帶一步跳投(MPP)"
#define KEY_FOR_MPP @"mpp"
#define TITLE_FOR_MPD @"掩護者持球切入(MPD)"
#define KEY_FOR_MPD @"mpd"
#define TITLE_FOR_MPS @"掩護者外翻原地跳投(MPS)"
#define KEY_FOR_MPS @"mps"
#define TITLE_FOR_PUT_BACK @"補籃(PB)"
#define KEY_FOR_PUT_BACK @"pb"
#define TITLE_FOR_SF @"要位第一拍出手(SF)"
#define KEY_FOR_SF @"sf"
#define TITLE_FOR_LP @"低位單打(LP)"
#define KEY_FOR_LP @"lp"


#define KEY_FOR_STOLEN @"Stolen"
#define KEY_FOR_BAD_PASS @"Bad Pass"
#define KEY_FOR_CHARGING @"Charging"
#define KEY_FOR_DROP @"Drop"
#define KEY_FOR_LINE @"Line"
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
#define KEY_FOR_DEFLECTION @"deflection"
#define KEY_FOR_GOOD @"good"
#define KEY_FOR_BAD @"bad"
#define KEY_FOR_TOTAL_COUNT @"total"

//Key for timeLine event
#define KEY_FOR_PLAYER_ON_FLOOR @"playerOnFloor"
#define KEY_FOR_TIME_LINE_DATA @"timeLineData"
#define KEY_FOR_PLAYER_NO @"playerNo"
#define KEY_FOR_OFF_MODE @"offMode"
#define KEY_FOR_SHOT_MODE @"shotMode"
#define KEY_FOR_RESULT @"result"
#define KEY_FOR_PTS @"Pts"
#define KEY_FOR_BONUS @"Bonus"
#define KEY_FOR_TYPE @"type"

#define SIGNAL_FOR_EXCHANGE @"Exchange"
#define SIGNAL_FOR_NORMAL @"Normal"
#define SIGNAL_FOR_BONUS @"bonus"
#define SIGNAL_FOR_FOUL @"foul"
#define SIGNAL_FOR_AND_ONE @"And 1"
#define SIGNAL_FOR_ATTEMPT @"noMade"
#define SIGNAL_FOR_MADE @"made"
#define SIGNAL_FOR_TURNOVER @"turnover"

//Defense
#define KEY_FOR_TIP @"tip"
#define KEY_FOR_CLOSE_OUT @"closeOut"
#define KEY_FOR_STOP_BALL @"stopBall"
#define KEY_FOR_BLOCK @"block"
#define KEY_FOR_STEAL @"steal"
#define KEY_FOR_EIGHT_24 @"eight24"
#define KEY_FOR_DOUBLE_TEAM @"doubleTeam"
#define KEY_FOR_LOOSE_BALL @"looseBall"
#define KEY_FOR_OFF_REB @"offReb"
#define KEY_FOR_DEF_REB @"defReb"
#define KEY_FOR_OFF_REB_TIP @"offRebTip"
#define KEY_FOR_WIDE_OPEN @"wideOpen"
#define KEY_FOR_NO_BLOCK_OUT @"noBlockOut"
#define KEY_FOR_DEF_ASSIST @"defAssist"
#define KEY_FOR_BLOWN_BY @"blownBy"

//Box Score
#define KEY_FOR_2_PTS @"2PTS"
#define KEY_FOR_3_PTS @"3PTS"
#define KEY_FOR_FREE_THROW @"Free Throw"
#define KEY_FOR_ASSIST @"assist"
#define KEY_FOR_STEAL @"steal"
#define KEY_FOR_BLOCK @"block"
#define KEY_FOR_FOUL @"foul"

//Dropbox
#define NAME_OF_THE_FINAL_XLSX_FILE @"PPP數據"
#define NAME_OF_THE_SHOT_CHART_XLSX_FILE @"Shot Chart"
#define NAME_OF_THE_ZONE_GRADE_XLSX_FILE @"投籃分佈圖"

//Signal For Game Type
#define REGULAR_GAME @"例行賽"
#define PLAYOFFS_GAME @"季後賽"

//URL For Post Request
#define URL_FOR_GENERAL_REQUEST @"http://basketball.beta.biji.co/api/addSblPlayerGeneralStats"
#define URL_FOR_SHOT_CHART_REQUEST @"http://basketball.beta.biji.co/api/addSblPlayerShotStats"
#define URL_FOR_DEFENSE_REQUEST @"http://basketball.beta.biji.co/api/addSblPlayerDefenseStats"
#define URL_FOR_TIME_LINE_REQUEST @"http://basketball.beta.biji.co/api/addSblPlayerTimelineStats"
#define URL_FOR_TIME_LINE_UP_AND_DOWN_REQUEST @"http://basketball.beta.biji.co/api/addSblPlayerTimelineUpAndDown"
#define URL_FOR_GAME_SCORE_REQUEST @"http://basketball.beta.biji.co/api/updateSblGameScores"

//Key For POST Request
#define KEY_FOR_GAME_SEASON @"gameSeason"
#define KEY_FOR_GAME_TYPE @"gameType"
#define KEY_FOR_GAME_NO @"gameNo"
#define KEY_FOR_TEAM_NAME @"teamName"

//Key For POST Request "addSblPlayerGeneralStats"
#define KEY_FOR_STARTING @"starting"
#define KEY_FOR_2PT_MADE @"2ptMade"
#define KEY_FOR_2PT_ATTEMPT @"2ptAtt"
#define KEY_FOR_3PT_MADE @"3ptMade"
#define KEY_FOR_3PT_ATTEMPT @"3ptAtt"
#define KEY_FOR_FT_MADE @"ftMade"
#define KEY_FOR_FT_ATTEMPT @"ftAtt"
#define KEY_FOR_OFF_REB @"offReb"
#define KEY_FOR_DEF_REB @"defReb"
#define KEY_FOR_TOTAL_REB @"totalReb"
#define KEY_FOR_POINT @"point"
#define KEY_FOR_PLAY_TIME @"playTime"

//Key For Post Request "addSblPlayerTimelineStats"
#define KEY_FOR_GAME_QUARTER @"gameQuarter"
#define KEY_FOR_QUARTER_MIN @"quarterMin"
#define KEY_FOR_QUARTER_SEC @"quarterSec"

//Key For Post Request "addSblPlayerTimelineUpAndDown"
#define KEY_FOR_UP_ONE @"upPlayer1No"
#define KEY_FOR_UP_TWO @"upPlayer2No"
#define KEY_FOR_UP_THREE @"upPlayer3No"
#define KEY_FOR_UP_FOUR @"upPlayer4No"
#define KEY_FOR_UP_FIVE @"upPlayer5No"
#define KEY_FOR_DOWN_ONE @"downPlayer1No"
#define KEY_FOR_DOWN_TWO @"downPlayer2No"
#define KEY_FOR_DOWN_THREE @"downPlayer3No"
#define KEY_FOR_DOWN_FOUR @"downPlayer4No"
#define KEY_FOR_DOWN_FIVE @"downPlayer5No"

//Key For Post Request "updateSblGameScores"
#define KEY_FOR_HOME_Q1_SCORE @"homeQ1Score"
#define KEY_FOR_HOME_Q2_SCORE @"homeQ2Score"
#define KEY_FOR_HOME_Q3_SCORE @"homeQ3Score"
#define KEY_FOR_HOME_Q4_SCORE @"homeQ4Score"
#define KEY_FOR_HOME_OT1_SCORE @"homeOt1Score"
#define KEY_FOR_HOME_OT2_SCORE @"homeOt2Score"
#define KEY_FOR_HOME_OT3_SCORE @"homeOt3Score"
#define KEY_FOR_AWAY_TEAM_NAME @"awayTeamName"

#define END -1
#define QUARTER_NO_FOR_ENTIRE_GAME 0



#endif /* BBRMacro_h */
