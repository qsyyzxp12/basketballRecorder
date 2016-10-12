//
//  BBRDropboxCheckViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/4/12.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRDropboxCheckViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BBRDropboxCheckViewController ()

@end

@implementation BBRDropboxCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if ([[DBSession sharedSession] isLinked])
  //      [[DBSession sharedSession] unlinkAll];
    [self performSelectorInBackground:@selector(checkingDropboxAuthorization) withObject:nil];
}

- (void)checkingDropboxAuthorization
{
    if (![[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] linkFromController:self];
    while (![[DBSession sharedSession] isLinked]);
  //  {
    //    NSLog(@"xxx");
   // };
    [self performSelectorOnMainThread:@selector(showMenuSegue) withObject:nil waitUntilDone:NO];

    //[self performSegueWithIdentifier:@"showMenuSegue" sender:nil];
}

-(void) showMenuSegue
{
    [self performSegueWithIdentifier:@"showMenuSegue" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
