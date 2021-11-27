//
//  cube222.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-2.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Cube222.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@interface Cube222 ()

@end

@implementation Cube222

char p2prun[5040];
short perm2mv[5040][3];
char t2prun[729];
short twst2mv[729][3];
NSArray *turn2;
NSArray *suf2;
int sol222[12];
bool ini222=false;

- (void) idxToPrm: (int[])ps p:(int)p {
    int q = p;
    for (int a = 1; a <= 7; a++) {
        int b = q % a;
        q = (q - b) / a;
        for (int c = a - 1; c >= b; c--)
            ps[c + 1] = ps[c];
        ps[b] = 7 - a;
    }
}

- (int) prmToIdx: (int[]) ps {
    int q = 0;
    for (int a = 0; a < 7; a++) {
        int b = 0;
        for (int c = 0; c < 7; c++) {
            if (ps[c] == a) break;
            if (ps[c] > a) b++;
        }
        q = q * (7 - a) + b;
    }
    return q;
}

- (int) get2prmmv: (int)p m:(int)m {
    int ps[8];
    [self idxToPrm:ps p:p];
    int c;
    switch (m) {
        case 0: 
            c = ps[0]; ps[0] = ps[1]; ps[1] = ps[3]; ps[3] = ps[2]; ps[2] = c;
            break;
        case 1:
            c = ps[0]; ps[0] = ps[4]; ps[4] = ps[5]; ps[5] = ps[1]; ps[1] = c;
            break;
        default:
            c = ps[0]; ps[0] = ps[2]; ps[2] = ps[6]; ps[6] = ps[4]; ps[4] = c;
            break;
    }
    return [self prmToIdx:ps];
}

- (void) idxToTws: (int[])ps p:(int)p {
    int q = p, d = 0;
    for (int a = 0; a <= 5; a++) {
        int c = q / 3;
        int b = q - 3 * c;
        q = c;
        ps[a] = b;
        d -= b;
        if (d < 0) d += 3;
    }
    ps[6] = d;
}

- (int) twsToIdx:(int[]) ps {
    int q = 0;
    for (int a = 5; a >= 0; a--) {
        q = q * 3 + (ps[a] % 3);
    }
    return q;
}

- (int)get2twsmv: (int)p m:(int)m {
    int ps[7];
    [self idxToTws:ps p:p];
    int c;
    if (m == 0) {
        c = ps[0]; ps[0] = ps[1]; ps[1] = ps[3]; ps[3] = ps[2]; ps[2] = c;
    }
    else if (m == 1) {
        c = ps[0]; ps[0] = ps[4]; ps[4] = ps[5]; ps[5] = ps[1]; ps[1] = c;
        ps[0] += 2; ps[1]++; ps[5] += 2; ps[4]++;
    }
    else if (m == 2) {
        c = ps[0]; ps[0] = ps[2]; ps[2] = ps[6]; ps[6] = ps[4]; ps[4] = c;
        ps[2] += 2; ps[0]++; ps[4] +=2 ; ps[6]++;
    }
    return [self twsToIdx:ps];
}

- (void) calc2perm {
    if(ini222)return;
    for (int p = 0; p < 5040; p++) {
        p2prun[p] = -1;
        for (int m = 0; m < 3; m++) {
            perm2mv[p][m] = [self get2prmmv:p m:m];
        }
    }
    p2prun[0] = 0;
    for (int l = 0; l <= 6; l++)
        for (int p = 0; p < 5040; p++) {
            if (p2prun[p] == l)
                for (int m = 0; m < 3; m++) {
                    int q = p;
                    for (int c = 0; c < 3; c++) {
                        q = perm2mv[q][m];
                        if (p2prun[q] == -1)
                            p2prun[q] = l + 1;
                    }
                }
    }
    for (int p = 0; p < 729; p++) {
        t2prun[p] = -1;
        for (int m = 0; m < 3; m++) {
            twst2mv[p][m] = [self get2twsmv:p m:m];
        }
    }
    t2prun[0] = 0;
    for (int l = 0; l <= 5; l++)
        for (int p = 0; p < 729; p++)
            if (t2prun[p] == l)
                for (int m = 0; m < 3; m++) {
                    int q = p;
                    for (int c = 0; c < 3; c++) {
                        q = twst2mv[q][m];
                        if (t2prun[q] == -1)
                            t2prun[q] = l + 1;
                    }
                }
    ini222 = true;
}

- (Cube222 *)init {
    if(self = [super init]) {
        turn2 = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
        suf2 = [[NSArray alloc] initWithObjects:@"'", @"2", @"", nil];
        [self calc2perm];
        srand((unsigned)time(0));
    }
    return self;
}

- (BOOL) search222: (int)q t:(int)t l:(int)l lm:(int)lm {
    if (l == 0) return q == 0 && t == 0;
    if (p2prun[q] > l || t2prun[t] > l) return false;
    int p,s,a,m;
    for (m = 0; m < 3; m++) {
        if (m != lm) {
            p = q; s = t;
            for (a = 0; a < 3; a++) {
                p = perm2mv[p][m];
                s = twst2mv[s][m];
                if ([self search222:p t:s l:(l-1) lm:m]) {
                    sol222[l] = m*3+a;
                    return true;
                }
            }
        }
    }
    return false;
}

- (NSString *)scr222 {
    int q = rand() % 5040;
    int t = rand() % 729;
    
    NSMutableString *s = [NSMutableString string];
    
    if(q != 0 || t != 0) {
        for (int l=0; l<12; l++) {
            if ([self search222:q t:t l:l lm:-1]) {
                for(int i=1; i<=l; i++) {
                    [s appendFormat:@"%@%@ ", [turn2 objectAtIndex:(sol222[i]/3)], [suf2 objectAtIndex:(sol222[i]%3)]];
                }
                return s;
            }
        }
    }
    return @"";
}

- (NSString *)scrCLL {
    int q = rand() % 24;
    int t = rand() % 27;
    int temp[8];
    idxToPerm(temp, q, 4);
    for(int i=4; i<8; i++)temp[i]=i;
    q = [self prmToIdx:temp];
    idxToZsOri(temp, t, 3, 4);
    for(int i=4; i<8; i++)temp[i]=0;
    t = [self twsToIdx:temp];
    
    NSMutableString *s = [NSMutableString string];
    if(q != 0 || t != 0) {
        for (int l=0; l<12; l++) {
            if ([self search222:q t:t l:l lm:-1]) {
                for(int i=1; i<=l; i++) {
                    [s appendFormat:@"%@%@ ", [turn2 objectAtIndex:(sol222[i]/3)], [suf2 objectAtIndex:(sol222[i]%3)]];
                }
                return s;
            }
        }
    }
    return @"";
}

- (NSString *)scrEG1 {
    int q = rand() % 24;
    int t = rand() % 27;
    int temp[8];
    idxToPerm(temp, q, 4);
    for(int i=4; i<8; i++)temp[i]=i;
    switch (rand()%2) {
        case 0:
            temp[4] = 5; temp[5] = 4;
            break;
        default:
            temp[4] = 6; temp[6] = 4;
            break;
    }
    q = [self prmToIdx:temp];
    idxToZsOri(temp, t, 3, 4);
    for(int i=4; i<8; i++)temp[i]=0;
    t = [self twsToIdx:temp];
    
    NSMutableString *s = [NSMutableString string];
    if(q != 0 || t != 0) {
        for (int l=0; l<12; l++) {
            if ([self search222:q t:t l:l lm:-1]) {
                for(int i=1; i<=l; i++) {
                    [s appendFormat:@"%@%@ ", [turn2 objectAtIndex:(sol222[i]/3)], [suf2 objectAtIndex:(sol222[i]%3)]];
                }
                return s;
            }
        }
    }
    return @"";
}

- (NSString *)scrEG2 {
    int q = rand() % 24;
    int t = rand() % 27;
    int temp[8];
    idxToPerm(temp, q, 4);
    for(int i=4; i<8; i++)temp[i]=i;
    temp[5] = 6; temp[6] = 5;
    q = [self prmToIdx:temp];
    idxToZsOri(temp, t, 3, 4);
    for(int i=4; i<8; i++)temp[i]=0;
    t = [self twsToIdx:temp];
    
    NSMutableString *s = [NSMutableString string];
    if(q != 0 || t != 0) {
        for (int l=0; l<12; l++) {
            if ([self search222:q t:t l:l lm:-1]) {
                for(int i=1; i<=l; i++) {
                    [s appendFormat:@"%@%@ ", [turn2 objectAtIndex:(sol222[i]/3)], [suf2 objectAtIndex:(sol222[i]%3)]];
                }
                return s;
            }
        }
    }
    return @"";
}

@end
