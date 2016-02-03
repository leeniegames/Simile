//
//  MatchesViewController.m
//  Similie
//
//  Created by Leenie Games Mac on 1/13/16.
//  Copyright © 2016 LeenieGames. All rights reserved.
//

#import "MatchesViewController.h"
#import <Parse/Parse.h>

@interface MatchesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MatchesViewController{
    NSArray *myLikes;
    NSMutableArray *profiles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    myLikes = [[PFUser currentUser] objectForKey:@"likes"];
    
    
    PFQuery *pquery = [PFQuery queryWithClassName:@"Accepted"];
    [pquery whereKey:@"user" equalTo:[PFUser currentUser]];
    [pquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        profiles = [NSMutableArray arrayWithArray:objects];
        [_tableView reloadData];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchesCell"];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *percentLabel = (UILabel *)[cell viewWithTag:3];
    
    
    percentLabel.text = [NSString stringWithFormat:@"%.0f%%", [[profiles[indexPath.row] objectForKey:@"percentage"]floatValue]];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return profiles.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
