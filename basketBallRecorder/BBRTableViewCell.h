//
//  BBRTableViewCell.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBRTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *indexLabel;
@property (strong, nonatomic) IBOutlet UITextField *numberTextField;
@property (strong, nonatomic) IBOutlet UILabel *NoLabel;
@property (strong, nonatomic) IBOutlet UIButton* titleButton;
@end
