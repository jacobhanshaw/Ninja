/////
//  ColorButton.m
//  Ninja
//
//  Created by Jacob Hanshaw on 9/25/12.
//
//

#import "ColorButton.h"

@implementation ColorButton

@synthesize solidColorView;


- (id)initWithFrame:(CGRect)inputFrame andImage:(UIColor *) inputColor
{
    self = [super initWithFrame:inputFrame];
    if (self) {
        hasTitle = NO;
        self.frame = inputFrame;
        self.solidColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.solidColorView.backgroundColor = inputColor;
        [self addSubview:self.solidColorView];
        [self.solidColorView.layer setCornerRadius:9.0];
        [self.layer setCornerRadius:9.0];
      //  [self.titleLabel removeFromSuperview];
    }
    return self;
}

- (id)initWithFrame:(CGRect)inputFrame andImage:(UIColor *) inputColor andTitle:(NSString *) inputTitle
{
    self = [super initWithFrame:inputFrame];
    if (self) {
        hasTitle = YES;
        self.frame = inputFrame;
        self.solidColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, (self.frame.size.height-15))];
        self.solidColorView.backgroundColor = inputColor;
        [self addSubview:self.solidColorView];
        [self setTitle:inputTitle forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self.solidColorView.layer setCornerRadius:9.0];
        [self.layer setCornerRadius:9.0];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(hasTitle){
    CGRect colorFrame = CGRectMake(0, 0, self.frame.size.width, (self.frame.size.height-15));
    self.solidColorView.frame = colorFrame;
    
    CGRect textFrame = CGRectMake(0, (self.frame.size.height-10), self.frame.size.width, 10);
    self.titleLabel.frame = textFrame;
    }
    
    else {
    CGRect colorFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.solidColorView.frame = colorFrame;
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
