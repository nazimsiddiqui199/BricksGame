//
//  ViewController.m
//  BricksGame
//
//  Created by Nazim Siddiqui on 09/04/18.
//  Copyright © 2018 Nazim Siddiqui. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"
#import "BricksView.h"
#import "BasePaddleView.h"

@interface ViewController () <UICollisionBehaviorDelegate>

@property(nonatomic) BOOL isGamePlayed;
@property(nonatomic, strong) UIDynamicAnimator *animatorView;
@property(nonatomic, strong) BallView *ballView;
@property(nonatomic, strong) BasePaddleView *basePaddleView;
@property(nonatomic, strong) NSMutableArray *bricksViewArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawInitialSetofOfView];
}

-(void)drawInitialSetofOfView
{
    if (_basePaddleView) {
        [_basePaddleView removeFromSuperview];
    }
    if (_ballView) {
        [_ballView removeFromSuperview];
    }
    
    //Allocate the base paddle view
    _basePaddleView = [[BasePaddleView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height - 35, 120, 30)];
    _basePaddleView.backgroundColor = [UIColor magentaColor];
    _basePaddleView.layer.cornerRadius = 4.0;
    _basePaddleView.layer.shadowRadius = 3.0;
    [self.view addSubview:_basePaddleView];
    
    //Initailize the ball View
    _ballView = [[BallView alloc] initWithFrame:CGRectMake(_basePaddleView.center.x - 10, _basePaddleView.center.y - 55, 40, 40)];
    _ballView.backgroundColor = [UIColor yellowColor];
    _ballView.layer.cornerRadius = 20;
    [self.view addSubview:_ballView];
    
    _bricksViewArray = [[NSMutableArray alloc] init];
    
    float x = 8;
    
    float y = 80;
    
    CGSize mainScreenSize = self.view.bounds.size;
    
    //When retry tapped removed all the views
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[BricksView class]]) {
            [view removeFromSuperview];
        }
    }
    
    // Drwat the view
    for (NSInteger i =0; i< 24; i++) {
        
        BricksView *brickView = [[BricksView alloc] initWithFrame:CGRectMake(x, y, 50, 30)];
        brickView.layer.cornerRadius = 5.0;
        brickView.backgroundColor = [UIColor cyanColor];
        brickView.type = 0;
        if (i%10 == 0) {
            brickView.type = 1;
            brickView.backgroundColor = [UIColor darkGrayColor];
        }
        
        [self.view addSubview:brickView];
        [self.bricksViewArray addObject:brickView];
        
        x+= 70;
        // On New Line draw
        if (x> mainScreenSize.width - 8) {
            
            x = 8;
            y+= 45;
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.isGamePlayed) {
        
        self.animatorView = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        NSMutableArray *collisionArray = [[NSMutableArray alloc] initWithObjects:_ballView, _basePaddleView, nil];
        [collisionArray addObjectsFromArray:self.bricksViewArray];
        
        //Add Collison Behavious
        UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:collisionArray];
        collisionBehaviour.translatesReferenceBoundsIntoBoundary = YES;
        collisionBehaviour.collisionMode = UICollisionBehaviorModeEverything;
        collisionBehaviour.collisionDelegate = self;
        [collisionBehaviour addBoundaryWithIdentifier:@"GameFinsished" fromPoint:CGPointMake(0, [UIScreen mainScreen].bounds.size.height) toPoint: CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [_animatorView addBehavior:collisionBehaviour];
        
        UIDynamicItemBehavior *bricksBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:self.bricksViewArray];
        bricksBehaviour.density = 10000;
        bricksBehaviour.allowsRotation = false;
        [_animatorView addBehavior:bricksBehaviour];
        
        UIDynamicItemBehavior *paddleBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.basePaddleView]];
        paddleBehaviour.density = 10000;
        paddleBehaviour.allowsRotation = false;
        [_animatorView addBehavior:paddleBehaviour];
        
        UIDynamicItemBehavior *ballBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
        ballBehaviour.elasticity = 1.0;
        ballBehaviour.allowsRotation = false;
        ballBehaviour.resistance = 0;
        ballBehaviour.friction = 0;
        [self.animatorView addBehavior:ballBehaviour];
        
        UIPushBehavior *ballPushBehaviour = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
        ballPushBehaviour.active = YES;
        ballPushBehaviour.pushDirection = CGVectorMake(-1, -1);
        ballPushBehaviour.magnitude = 0.7;
        [self.animatorView addBehavior:ballPushBehaviour];
        
        self.isGamePlayed = YES;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    _basePaddleView.center = CGPointMake(touchPoint.x, _basePaddleView.center.y);
    
    [self.animatorView updateItemUsingCurrentState:self.basePaddleView];
}

#pragma mark:- Colloison Delegate

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item2 isKindOfClass:[BricksView class]]) {
        
        BricksView *hittedView = (BricksView *)item2;
        
        if (hittedView.type == 1) {
            hittedView.type--;
            hittedView.backgroundColor = [UIColor cyanColor];
        }else{
            
            hittedView.hidden = YES;
            [behavior removeItem:hittedView];
            [self.bricksViewArray removeObject:hittedView];
        }
        
        if (self.bricksViewArray.count == 0) {
            
            [self.animatorView removeAllBehaviors];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:@"You win the game. Would you like to play it again?" preferredStyle: UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.isGamePlayed = NO;
                [self drawInitialSetofOfView];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    NSString *touchIdentifier = (NSString *)identifier;
    if (item == self.ballView && [touchIdentifier isEqualToString:@"GameFinsished"]) {
        
        [self.animatorView removeAllBehaviors];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Game Over!" message:@"Would you like to play it again?" preferredStyle: UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.isGamePlayed = NO;
            [self drawInitialSetofOfView];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
