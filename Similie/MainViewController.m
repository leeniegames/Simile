//
//  MainViewController.m
//  Similie
//
//  Created by Leenie Games Mac on 12/31/15.
//  Copyright © 2015 LeenieGames. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import "MenuViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *skipMeButton;
@property (weak, nonatomic) IBOutlet UIImageView *addMeButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITableView *likesTable;

@end

@implementation MainViewController{
    NSMutableArray *potentials;
    int potentialsCursor;
    NSDictionary *currentPotential;
    NSArray *potentialLikes;
    
    NSArray *myLikes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    // display image from parse
    PFFile *imageFile = [[PFUser currentUser] objectForKey:@"picture"];
    UIImage *image = [UIImage imageWithData:[imageFile getData]];
    [_profileImageView setImage:image];
     */
    
    potentialsCursor = 0;
    currentPotential = @{};
    potentialLikes = @[];
    potentials = [NSMutableArray array];
    myLikes = [[PFUser currentUser] objectForKey:@"likes"];
    _infoLabel.text = @"";
    
    [_addMeButton setHidden:YES];
    [_skipMeButton setHidden:YES];
    
    [self showNextPotential];
    
}

-(void)viewDidLayoutSubviews{
    
}

-(void)displayProfile{
    currentPotential = [potentials objectAtIndex:potentialsCursor];
    
    PFFile *pi = [currentPotential objectForKey:@"picture"];
    [pi getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        
        if(!error){
            [_profileImageView setImage:[UIImage imageWithData:data]];
        }else{
            NSLog(@"error: %@", error.description);
        }
        
    }];
    
    potentialLikes = [currentPotential objectForKey:@"likes"];
    
    [_likesTable reloadData];
    
    [self setPercentageLabel];
    
    //[_likesTable reloadRowsAtIndexPaths:[_likesTable indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    
    [_addMeButton setHidden:NO];
    [_skipMeButton setHidden:NO];
    
}

-(void)showNextPotential{
    potentialsCursor++;
    if (potentialsCursor>=potentials.count) {
        [self reloadPotientials];
    }else{
        [self displayProfile];
    }
}

-(void)reloadPotientials{
    NSLog(@"reloadPotentials");
    
    PFQuery *profilesQuery = [PFQuery queryWithClassName:@"testUser"];
    [profilesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        if(!error){
            potentials = [NSMutableArray arrayWithArray:[objects copy]];
            potentialsCursor = 0;
            [self displayProfile];
        }else{
            NSLog(@"error: %@", error.description);
        }
    }];
    
}

-(void)setPercentageLabel{
    
    _infoLabel.text = [NSString stringWithFormat:@"similie: %.0f%%", [self getPercentage]];
}

-(float)getPercentage{
    
    float totalMatches = 0.0f;
    for (NSString *l in myLikes) {
        
        if([potentialLikes containsObject:l]){
            ++totalMatches;
        }
    }
    
    float percentage = 0.0f;
    if (totalMatches>0.0) {
        percentage = totalMatches/myLikes.count;
    }
    
    return percentage*100;
    
}

// table view delegates and data

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *likes = potentialLikes;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainTableCell"];
    if([myLikes containsObject:likes[indexPath.row]]){
        cell.textLabel.textColor = [UIColor greenColor];
    }else{
        cell.textLabel.textColor = [UIColor colorWithRed:21.0f/255.0f green:40.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
    }
    cell.textLabel.text = likes[indexPath.row];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return potentialLikes.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPos = [[touches anyObject]locationInView:self.view];
    
    if(!_addMeButton.isHidden&&CGRectContainsPoint(_addMeButton.frame, touchPos)){
        // add to similies array
        [_addMeButton setHidden:YES];
        [_skipMeButton setHidden:YES];
        
        PFObject *accepted = [PFObject objectWithClassName:@"Accepted"];
        accepted[@"profile"] = currentPotential;
        accepted[@"user"] = [PFUser currentUser];
        accepted[@"percentage"] = [NSNumber numberWithFloat:[self getPercentage]];
        
        [accepted saveInBackground];
        
        [self showNextPotential];
    }
    
    if(!_skipMeButton.isHidden&&CGRectContainsPoint(_skipMeButton.frame, touchPos)){
        // add to reject array
        [_addMeButton setHidden:YES];
        [_skipMeButton setHidden:YES];
        
        PFObject *rejected = [PFObject objectWithClassName:@"Rejected"];
        rejected[@"profile"] = currentPotential;
        rejected[@"user"] = [PFUser currentUser];
        
        [rejected saveInBackground];

        
        [self showNextPotential];
    }
    
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
