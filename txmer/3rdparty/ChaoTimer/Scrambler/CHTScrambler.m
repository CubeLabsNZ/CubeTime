//
//  CHTScrambler.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTScrambler.h"
#import "Cube222.h"
#import "Pyraminx.h"
#import "Megaminx.h"
#import "Cross.h"
#import "Sq12phase.h"
//#import "Tower.h"
#import "Skewb.h"
#import "TwoPhaseScrambler.h"
#import "Clock.h"
#import "SQ1.h"
#import "Gear.h"
//#import "LatchCube.h"
//#import "Floppy.h"
//#import "RTower.h"
//#import "EOLine.h"
#import "stdlib.h"
#import "time.h"

@interface CHTScrambler()

@property (nonatomic, strong) Cube222 *cube222;
@property (nonatomic, strong) Pyraminx *pyraminx;
@property (nonatomic, strong) Megaminx *megaminx;
@property (nonatomic, strong) Clock *clock;
@property (nonatomic, strong) SQ1 *sq1o;
@property (nonatomic, strong) Cross *cross;
@property (nonatomic, strong) TwoPhaseScrambler *cube33;
@property (nonatomic, strong) Sq12phase *sq1;
@property (nonatomic, strong) Skewb *skewb;
@property (nonatomic, strong) Gear *gear;
@end

@implementation CHTScrambler

@synthesize cube222 = _cube222;
@synthesize pyraminx = _pyraminx;
@synthesize megaminx = _megaminx;
@synthesize clock = _clock;
@synthesize sq1o = _sq1o;
@synthesize cross = _cross;
@synthesize cube33 = _cube33;
@synthesize sq1 = _sq1;
@synthesize skewb = _skewb;
@synthesize gear = _gear;

- (id)init {
    if(self = [super init]) {
        srand((unsigned)time(0));
        //cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    }
    return self;
}

- (NSString *)scramble222: (int) type {
    if(!_cube222)
        self.cube222 = [[Cube222 alloc] init];
    if(type==0) return [self.cube222 scr222];
    else if(type==1) return [self.cube222 scrCLL];
    else if(type==2) return [self.cube222 scrEG1];
    else return [self.cube222 scrEG2];
}

- (NSString *)scramblePyrm {
    if(!_pyraminx)
        self.pyraminx = [[Pyraminx alloc] init];
    return [self.pyraminx scrPyrm];
}

- (NSString *)scrambleMinx {
    if(!_megaminx)
        self.megaminx = [[Megaminx alloc] init];
    return [self.megaminx scrMinx];
}

- (NSString *)scrambleClk: (int) type {
    if(!_clock)
        self.clock = [[Clock alloc] init];
    if(type==0)
        return [self.clock scramble];
    else if(type==1)
        return [self.clock scrambleOld: false];
    else if(type==2)
        return [self.clock scrambleOld: true];
    else return [self.clock scrambleEpo];
}

- (NSString *)scrambleSq: (int)type {
    if(!_sq1o)
        self.sq1o = [[SQ1 alloc] init];
    if(type==0)
        return [self.sq1o sq1_scramble:1];
    else if(type==1)
        return [self.sq1o sq1_scramble:0];
    else if(type==2)
        return [self.sq1o ssq1t_scramble];
    else return [self.sq1o sq1_scramble:2];
}

- (NSString *)solveCross: (NSString *)scr side:(int)side {
    if(!_cross)
        self.cross = [[Cross alloc] init];
    return [self.cross cross:scr side:side];
}

- (NSString *)solveXcross:(NSString *)scr side:(int)side {
    if(!_cross)
        self.cross = [[Cross alloc] init];
    return [self.cross xcross:scr side:side];
}


- (NSString *)scramble333: (int) type {
    if(!_cube33) self.cube33 = [[TwoPhaseScrambler alloc] init];
    NSString *temp = [self.cube33 scramble: type];
    return temp;
}


- (NSString *)megascramble: (NSArray *)turns len:(int)len suf:(NSArray *)suff sql:(int)sql {
    int donemoves[10];
    int lastaxis = -1, len2 = turns.count / len, slen = suff.count;
    //NSLog(@"%d %d", len2, slen);
    NSMutableString *s = [NSMutableString string];
    for (int j=0; j<sql; j++) {
        int done = 0;
        do {
            int first = rand()%len;
            int second = rand()%len2;
            if(first!=lastaxis || donemoves[second]!=1) {
                if(first!=lastaxis) {
                    for(int k=0; k<10; k++)donemoves[k]=0;
                    lastaxis = first;
                }
                donemoves[second] = 1;
                [s appendFormat:@"%@%@ ", [turns objectAtIndex:first*len2+second], [suff objectAtIndex:(rand()%slen)]];
                done = 1;
            }
        } while (done==0);
    }
    return s;
}

- (NSString *)megascramble:(NSArray *)turns suf:(NSArray *)suff sql:(int)len ia:(BOOL)isArray {
    int donemoves[10];
    int lastaxis = -1, slen = suff.count;
    //NSLog(@"%d %d", len2, slen);
    NSMutableString *s = [NSMutableString string];
    for (int j=0; j<len; j++) {
        int done = 0;
        do {
            int first = rand()%turns.count;
            int second = rand()%([[turns objectAtIndex:first] count]);
            if(first!=lastaxis) {
                for(int k=0; k<10; k++)donemoves[k]=0;
                lastaxis = first;
            }
            if(donemoves[second]!=1) {
                donemoves[second] = 1;
                if(isArray)
                    [s appendFormat:@"%@%@ ", [[[turns objectAtIndex:first] objectAtIndex:second] objectAtIndex:rand()%[[[turns objectAtIndex:first] objectAtIndex:second] count]], [suff objectAtIndex:(rand()%slen)]];
                else [s appendFormat:@"%@%@ ", [[turns objectAtIndex:first] objectAtIndex:second], [suff objectAtIndex:(rand()%slen)]];
                done = 1;
            }
        } while (done==0);
    }
    return s;
}

- (void) initSq1 {
    if(!_sq1)
        self.sq1 = [[Sq12phase alloc] init];
    [self.sq1 initsq];
}

- (NSString *)scrambleSq1 {
    if(!_sq1)
        self.sq1 = [[Sq12phase alloc] init];
    return [self.sq1 scrSq1];
}

- (NSString *)scrambleSkb {
    if(!_skewb)
        self.skewb = [[Skewb alloc] init];
    return [self.skewb scrSkb];
}

- (NSString *) yj4x4 {
    // the idea is to keep the fixed center on U and do Rw or Lw, Fw or Bw, to not disturb it
    //String[][] turns = {{"U","D"},{"R","L","r"},{"F","B","f"}};
    NSArray *turns = [[NSArray alloc] initWithObjects:@"U", @"D", @"", @"R", @"L", @"r", @"F", @"B", @"f", nil];
    int turnlen[] = {2,3,3};
    NSArray *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    int donemoves[3];
    int lastaxis,fpos = 0, // 0 = Ufr, 1 = Ufl, 2 = Ubl, 3 = Ubr
    j,k;
    NSMutableString *s = [NSMutableString string];
    lastaxis=-1;
    for(j=0;j<40;j++){
        int done=0;
        do{
            int first=rand()%3;
            int second=rand()%turnlen[first];
            if(first!=lastaxis||donemoves[second]==0){
                if(first==lastaxis){
                    donemoves[second]=1;
                    int rs = rand()%3;
                    if(first==0&&second==0){fpos = (fpos + 4 + rs)%4;}
                    if(first==1&&second==2){ // r or l
                        if(fpos==0||fpos==3) [s appendFormat:@"l%@ ", [cubesuff objectAtIndex:rs]];//s.append("l"+cubesuff[rs]+" ");
                        else [s appendFormat:@"r%@ ", [cubesuff objectAtIndex:rs]];//s.append("r"+cubesuff[rs]+" ");
                    } else if(first==2&&second==2){ // f or b
                        if(fpos==0||fpos==1) [s appendFormat:@"b%@ ", [cubesuff objectAtIndex:rs]];//s.append("b"+cubesuff[rs]+" ");
                        else [s appendFormat:@"f%@ ", [cubesuff objectAtIndex:rs]];//s.append("f"+cubesuff[rs]+" ");
                    } else {
                        [s appendFormat:@"%@%@ ", [turns objectAtIndex:first*3+second], [cubesuff objectAtIndex:rs]];
                        //s.append(turns[first][second]+cubesuff[rs]+" ");
                    }
                }else{
                    for(k=0;k<turnlen[first];k++){donemoves[k]=0;}
                    lastaxis=first;
                    donemoves[second]=1;
                    int rs = rand()%3;
                    if(first==0&&second==0){fpos = (fpos + 4 + rs)%4;}
                    if(first==1&&second==2){ // r or l
                        if(fpos==0||fpos==3) [s appendFormat:@"l%@ ", [cubesuff objectAtIndex:rs]];//s.append("l"+cubesuff[rs]+" ");
                        else [s appendFormat:@"r%@ ", [cubesuff objectAtIndex:rs]];//s.append("r"+cubesuff[rs]+" ");
                    } else if(first==2&&second==2){ // f or b
                        if(fpos==0||fpos==1) [s appendFormat:@"b%@ ", [cubesuff objectAtIndex:rs]];//s.append("b"+cubesuff[rs]+" ");
                        else [s appendFormat:@"f%@ ", [cubesuff objectAtIndex:rs]];//s.append("f"+cubesuff[rs]+" ");
                    } else {
                        [s appendFormat:@"%@%@ ", [turns objectAtIndex:first*3+second], [cubesuff objectAtIndex:rs]];
                        //s.append(turns[first][second]+cubesuff[rs]+" ");
                    }
                }
                done=1;
            }
        }while(done==0);
    }
    return s;
}

- (NSString *)scrambleGear {
    if(!_gear) self.gear = [[Gear alloc] init];
    NSString *scr = [self.gear scrGear];
    return scr;
}

- (NSString *) oldminxscramble {
    int j,k;
    NSArray *minxsuff =[[NSArray alloc] initWithObjects:@"", @"2", @"'", @"2'", nil];
    NSArray *faces = [[NSArray alloc] initWithObjects:@"F", @"B", @"U", @"D", @"L", @"DBR", @"DL", @"BR", @"DR", @"BL", @"R", @"DBL", nil];
    int used[12];
    // adjacency table
    int adj[] = {0x554, 0xaa8, 0x691, 0x962, 0xa45, 0x58a, 0x919, 0x626, 0x469, 0x896, 0x1a5, 0x25a};
    // now generate the scramble(s)
    NSMutableString *s = [NSMutableString string];
    for(j=0;j<12;j++){
        used[j] = 0;
    }
    for(j=0;j<70;j++){
        bool done = false;
        do {
            int face = rand()%12;
            if (used[face] == 0) {
                [s appendFormat:@"%@%@ ", [faces objectAtIndex:face], [minxsuff objectAtIndex:(rand()%4)]];
                //s.append(faces[face] + rndEl(minxsuff) + " ");
                for(k=0;k<12;k++){
                    if ((adj[face]>>k&1)==1)
                        used[k] = 0;
                }
                used[face] = 1;
                done = true;
            }
        } while (!done);
    }
    return s;
}

- (NSString *)edgeScramble: (NSString *)start end:(NSArray *)end moves:(NSArray *)moves len:(int)len{
    int u=0,d=0;
    int movemis[10];
    int movelen = moves.count;
    NSArray *triggers =[[NSArray alloc] initWithObjects:@"R",@"R'",@"R'",@"R",@"L",@"L'",@"L'",@"L",@"F'",@"F",@"F",@"F'",@"B",@"B'",@"B'",@"B", nil];
    NSArray *ud = [[NSArray alloc] initWithObjects:@"U", @"D", nil];
    NSArray *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    NSMutableString *ss = [NSMutableString stringWithString:start];
    NSString *v;
    for (int i=0; i<movelen; i++) {
        movemis[i] = 0;
    }
    for (int i=0; i<len; i++) {
        // apply random moves
        bool done = false;
        while (!done) {
            v = @"";
            for (int j=0; j<movelen; j++) {
                int x = rand()%4;
                movemis[j] += x;
                if (x!=0) {
                    done = true;
                    v = [v stringByAppendingFormat:@" %@%@", [moves objectAtIndex:j], [cubesuff objectAtIndex:x-1]];
                    //v += " " + moves[j] + cubesuff[x-1];
                }
            }
        }
        [ss appendString:v];
        
        // apply random trigger, update U/D
        int trigger = rand()%8;
        int layer = rand()%2;
        int turn = rand()%3;
        [ss appendFormat:@" %@ %@%@ %@", [triggers objectAtIndex:trigger*2], [ud objectAtIndex:layer], [cubesuff objectAtIndex:turn], [triggers objectAtIndex:trigger*2+1]];
        //ss += " " + triggers[trigger][0] + " " + ud[layer] + cubesuff[turn] + " " + triggers[trigger][1];
        if (layer==0) u += turn+1;
        if (layer==1) d += turn+1;
    }
    // fix everything
    for (int i=0; i<movelen; i++) {
        int x = 4-(movemis[i]%4);
        if (x<4) {
            [ss appendFormat:@" %@%@", [moves objectAtIndex:i], [cubesuff objectAtIndex:x-1]];
            //ss += " " + moves[i] + cubesuff[x-1];
        }
    }
    u = 4-(u%4); d = 4-(d%4);
    if (u<4) {
        [ss appendFormat:@" U%@", [cubesuff objectAtIndex:u-1]];
        //ss += " U" + cubesuff[u-1];
    }
    if (d<4) {
        [ss appendFormat:@" D%@", [cubesuff objectAtIndex:d-1]];
        //ss += " D" + cubesuff[d-1];
    }
    [ss appendFormat:@" %@", [end objectAtIndex:(rand()%end.count)]];
    //ss += " " + rndEl(end);
    return ss;
}


- (NSString *)getScrStringByType:(int)type subset: (int)subset {
    NSLog(@"scramble type: %d, %d", type, subset);
    NSString *scr = @"";
    NSArray *turn, *cubesuff = [[NSArray alloc] initWithObjects:@"", @"2", @"'", nil];
    switch (type) {
        case 0: // 2x2
            NSLog(@"2x2");
            switch (subset) {
                case 0:
                    scr = [self scramble222: 0];
                    break;
                case 1:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:15];
                    break;
                case 2:
                {
                    NSArray *turn1 = [[NSArray alloc] initWithObjects:@"U", @"D", nil];
                    NSArray *turn2 = [[NSArray alloc] initWithObjects:@"L", @"R", nil];
                    NSArray *turn3 = [[NSArray alloc] initWithObjects:@"F", @"B", nil];
                    turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
                    scr = [self megascramble:turn suf:cubesuff sql:15 ia:YES];
                    break;
                }
                case 3: //CLL
                case 4: //EG1
                case 5: //EG2
                    scr = [self scramble222: subset-2];
                    break;
                default:
                    break;
            }
            break;
        case 1: // 3x3
            NSLog(@"3x3");
            switch (subset) {
                case 0:    //3x3
                    scr = [self scramble333: 0];
                    break;
                case 1:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:25];
                     break;
                case 2:    //F2L
                case 3:    //LL
                case 4:    //PLL
                case 5:    //corner
                case 6:    //edge
                case 7:    //LSLL
                case 8:    //ZBLL
                case 9:    //COLL
                case 10:    //ELL
                case 11:    //l6e
                case 12:    //CMLL
                    scr = [self scramble333: subset-1];
                    break;
                default:
                    break;
            }
            break;
        case 2: // 4x4
            NSLog(@"4x4");
            switch (subset) {
                case 0:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"Uw", @"D", @"L", @"Rw", @"R", @"F", @"Fw", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:40];
                    break;
                case 1:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"D", @"L", @"r", @"R", @"F", @"f", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:40];
                    break;
                case 2:
                    scr = [self yj4x4];
                    break;
                case 3:
                {
                    NSString *start = @"Bw2 Rw'";
                    NSArray *end = [[NSArray alloc] initWithObjects:@"Bw2 Rw'", @"Bw2 U2 Rw U2 Rw U2 Rw U2 Rw", nil];
                    NSArray *moves = [[NSArray alloc] initWithObjects:@"Uw", nil];
                    scr = [self edgeScramble:start end:end moves:moves len:8];
                    break;
                }
                case 4:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"R", @"r", nil];
                    scr = [self megascramble:turn len:2 suf:cubesuff sql:40];
                    break;
                default:
                    break;
            }
            break;
        case 3: // 5x5
            NSLog(@"5x5");
            switch (subset) {
                case 0:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"Uw", @"Dw", @"D", @"L", @"Lw", @"Rw", @"R", @"F", @"Fw", @"Bw", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:60];
                    break;
                case 1:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"d", @"D", @"L", @"l", @"r", @"R", @"F", @"f", @"b", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:60];
                    break;
                case 2:
                {
                    NSString *start = @"Rw R Bw B";
                    NSArray *end = [[NSArray alloc] initWithObjects:@"B' Bw' R' Rw'", @"B' Bw' R' U2 Rw U2 Rw U2 Rw U2 Rw", nil];
                    NSArray *moves = [[NSArray alloc] initWithObjects:@"Uw", @"Dw", nil];
                    scr = [self edgeScramble:start end:end moves:moves len:8];
                    break;
                }
                default:
                    break;
            }
            break;
        case 4: // 6x6
            NSLog(@"6x6");
            switch (subset) {
                case 0:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"2U", @"3U", @"2D", @"D", @"L", @"2L", @"3R", @"2R", @"R", @"F", @"2F", @"3F", @"2B", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:80];
                    break;
                case 1:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"3u", @"d", @"D", @"L", @"l", @"3r", @"r", @"R", @"F", @"f", @"3f", @"b", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:80];
                    break;
                case 2:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"U²", @"U³", @"D²", @"D", @"L", @"L²", @"R³", @"R²", @"R", @"F", @"F²", @"F³", @"2B", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:80];
                    break;
                case 3:
                {
                    NSString *start = @"3r r 3b b";
                    NSArray *end = [[NSArray alloc] initWithObjects:@"3b' b' 3r' r'", @"3b' b' 3r' U2 r U2 r U2 r U2 r", @"3b' b' r' U2 3r U2 3r U2 3r U2 3r", nil];
                    NSArray *moves = [[NSArray alloc] initWithObjects:@"u", @"3u", @"d", nil];
                    scr = [self edgeScramble:start end:end moves:moves len:10];
                    break;
                }
                default:
                    break;
            }
            break;
        case 5: // 7x7
            NSLog(@"7x7");
            switch (subset) {
                case 0:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"2U", @"3U", @"3D", @"2D", @"D", @"L", @"2L", @"3L", @"3R", @"2R", @"R", @"F", @"2F", @"3F", @"3B", @"2B", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:100];
                    break;
                case 1:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"u", @"3u", @"3d", @"d", @"D", @"L", @"l", @"3l", @"3r", @"r", @"R", @"F", @"f", @"3f", @"3b", @"b", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:100];
                    break;
                case 2:
                    turn = [[NSArray alloc] initWithObjects:@"U", @"U²", @"U³", @"D³", @"D²", @"D", @"L", @"L²", @"L³", @"R³", @"R²", @"R", @"F", @"F²", @"F³", @"B³", @"B²", @"B", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:100];
                    break;
                case 3:
                {
                    NSString *start = @"3r r 3b b";
                    NSArray *end = [[NSArray alloc] initWithObjects:@"3b' b' 3r' r'", @"3b' b' 3r' U2 r U2 r U2 r U2 r", @"3b' b' r' U2 3r U2 3r U2 3r U2 3r", nil];
                    NSArray *moves = [[NSArray alloc] initWithObjects:@"u", @"3u", @"3d", @"d", nil];
                    scr = [self edgeScramble:start end:end moves:moves len:10];
                    break;
                }
                default:
                    break;
            }
            break;
        case 6: // sq1
            NSLog(@"sq1");
            switch (subset) {
                case 0:
                    scr = [self scrambleSq1];
                    break;
                case 1:
                case 2:
                    scr = [self scrambleSq:(subset -1)];
                    break;
                default:
                    break;
            }
            break;
        case 7: // megaminx
            NSLog(@"megaminx");
            switch (subset) {
                case 0:
                    scr = [self scrambleMinx];
                    break;
                case 1:
                    scr = [self oldminxscramble];
                    break;
                default:
                    break;
            }
            break;
        case 8: // pyraminx
            NSLog(@"pyraminx");
            switch (subset) {
                case 0:
                    scr = [self scramblePyrm];
                    break;
                case 1:
                {
                    int cnt=0;
                    int rnd[4];
                    for(int i=0;i<4;i++){
                        rnd[i]=rand()%3;
                        if(rnd[i]>0) cnt++;
                    }
                    NSArray *ss= [[NSArray alloc] initWithObjects:@"", @"b ", @"b' ", @"", @"l ", @"l' ", @"", @"u ", @"u' ", @"", @"r ", @"r' ", nil];
                    turn = [[NSArray alloc] initWithObjects:@"R", @"L", @"U", @"B", nil];
                    NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"'", nil];
                    scr = [NSString stringWithFormat:@"%@%@%@%@%@", [ss objectAtIndex:rnd[0]], [ss objectAtIndex:3+rnd[1]], [ss objectAtIndex:6+rnd[2]], [ss objectAtIndex:9+rnd[3]], [self megascramble:turn len:4 suf:suff sql:15-cnt]];
                }
                    break;
                default:
                    break;
            }
            
            break;
        case 9: // clock
            NSLog(@"clock");
            scr = [self scrambleClk:subset];
            break;
        case 10: // skewb
            NSLog(@"skewb");
            switch (subset) {
                case 0:
                    scr = [self scrambleSkb];
                    break;
                case 1:
                {
                    turn = [[NSArray alloc] initWithObjects:@"R", @"L", @"B", @"D", nil];
                    NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"'", nil];
                    scr = [self megascramble:turn len:4 suf:suff sql:15];
                }
                    break;
                default:
                    break;
            }
            break;
        case 11: // gear
            NSLog(@"gear");
            switch (subset) {
                case 0:
                    scr = [self scrambleGear];
                    break;
                case 1:
                {
                    turn = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
                    NSArray *suff = [[NSArray alloc] initWithObjects:@"", @"2", @"3", @"4", @"5", @"6", @"'", @"2'", @"3'", @"4'", @"5'", nil];
                    scr = [self megascramble:turn len:3 suf:suff sql:10];
                }
                    break;
                default:
                    break;
            }
            break;
        case 12: // 33sub
            NSLog(@"33subset");
            switch (subset) {
                case 0:    //R, U
                    turn = [[NSArray alloc] initWithObjects:@"R", @"U", nil];
                    scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
                    break;
                case 1:    //L, U
                    turn = [[NSArray alloc] initWithObjects:@"L", @"U", nil];
                    scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
                    break;
                case 2:    //M, U
                    turn = [[NSArray alloc] initWithObjects:@"M", @"U", nil];
                    scr = [self megascramble:turn len:2 suf:cubesuff sql:25];
                    break;
                case 3:    //F, R, U
                    turn = [[NSArray alloc] initWithObjects:@"F", @"R", @"U", nil];
                    scr = [self megascramble:turn len:3 suf:cubesuff sql:25];
                    break;
                case 4:    //R, U, L
                {
                    NSArray *turn1 = [[NSArray alloc] initWithObjects:@"L", @"R", nil];
                    NSArray *turn2 = [[NSArray alloc] initWithObjects:@"U", nil];
                    turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
                    scr = [self megascramble:turn suf:cubesuff sql:25 ia:false];
                }
                    break;
                case 5:    //R, r, U
                {
                    NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R", @"r", nil];
                    NSArray *turn2 = [[NSArray alloc] initWithObjects:@"U", nil];
                    turn = [[NSArray alloc] initWithObjects:turn1, turn2, nil];
                    scr = [self megascramble:turn suf:cubesuff sql:25 ia:false];
                }
                    break;
                case 6:    //half turns
                {
                    turn = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
                    NSArray *suff = [[NSArray alloc] initWithObjects:@"2", nil];
                    scr = [self megascramble:turn len:3 suf:suff sql:25];
                }
                    break;
                case 7:    //LSLL
                {
                    NSArray *turn1 = [[NSArray alloc] initWithObjects:@"R U R'", @"R U2 R'", @"R U' R'", nil];
                    NSArray *turn2 = [[NSArray alloc] initWithObjects:@"F' U F", @"F' U2 F", @"F' U' F", nil];
                    NSArray *turn3 = [[NSArray alloc] initWithObjects:@"U", @"U2", @"U'", nil];
                    turn = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:turn1, nil], [[NSArray alloc] initWithObjects:turn2, nil], [[NSArray alloc] initWithObjects:turn3, nil], nil];
                    NSArray *suff = [[NSArray alloc] initWithObjects:@"", nil];
                    scr = [self megascramble:turn suf:suff sql:25 ia:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    NSLog(@"New Scramble: %@", scr);
    return scr;
}

+ (NSArray *) scrambleTypes {
    return [[NSArray alloc] initWithObjects:@"2x2x2", @"3x3x3", @"4x4x4", @"5x5x5", @"6x6x6", @"7x7x7", @"Square-1", @"Megaminx", @"Pyraminx",  @"Clock", @"Skewb", @"Gear", @"3x3 subsets", nil];
}
@end
