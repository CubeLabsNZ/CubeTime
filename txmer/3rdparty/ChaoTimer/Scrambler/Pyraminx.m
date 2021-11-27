//
//  Pyraminx.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 12-11-3.
//  Copyright (c) 2012年 MeigenChou. All rights reserved.
//

#import "Pyraminx.h"
#import "stdlib.h"
#import "time.h"

@interface Pyraminx ()

@end

@implementation Pyraminx
int posit[36];
char pPymPrun[720];
short permPymmv[720][4];
char tPymPrun[2592];
short twstPymmv[2592][4];
int pcperm[6] = {0, 1, 2, 3, 4, 5}; 
int pcori[10];

NSArray *facePym;
NSArray *sufPym;
NSArray *tipsPym;
int solPym[13];
int sollen;

- (void) cycle3: (int[])arr i1:(int)i1 i2:(int)i2 i3:(int)i3 {
    int c = arr[i1];
    arr[i1] = arr[i2];
    arr[i2] = arr[i3];
    arr[i3] = c;
}

- (int) getPymPermmv: (int)p m:(int)m  {
    int a,b,c,q = p;
    int ps[7];
    for (a = 1; a <= 6; a++) {
        c = q / a;
        b = q - (a * c);
        q = c;
        for (c = a - 1; c >= b; c--) {
            ps[c + 1] = ps[c];
        }
        ps[b] = 6 - a;
    }
    if (m == 0) {
        [self cycle3:ps i1:0 i2:3 i3:1];
    }
    else if (m == 1) {
        [self cycle3:ps i1:1 i2:5 i3:2];
    }
    else if (m == 2) {
        [self cycle3:ps i1:0 i2:2 i3:4];
    }
    else if (m == 3) {
        [self cycle3:ps i1:3 i2:4 i3:5];
    }
    q = 0;
    for (a = 0; a < 6; a++) {
        b = 0;
        for (c = 0; c < 6; c++) {
            if (ps[c] == a) break;
            if (ps[c] > a) b++;
        }
        q = q * (6 - a) + b;
    }
    return q;
}

- (int)getPymTwsmv: (int)p m:(int)m {
    int ps[10];
    int a, d = 0, b, c, q = p;
    for (a = 0; a <= 4; a++) {
        ps[a] = q & 1;
        q >>= 1;
        d ^= ps[a];
    }
    ps[5] = d;
    for (a = 6; a <= 9; a++) {
        c = q / 3;
        b = q - 3 * c;
        q = c;
        ps[a] = b;
    }
    if (m == 0) {
        ps[6]++; if (ps[6] == 3) ps[6] = 0;
        [self cycle3:ps i1:0 i2:3 i3:1];
        ps[1] ^= 1; ps[3] ^= 1;
    }
    else if (m == 1) {
        ps[7]++; if (ps[7] == 3) ps[7] = 0;
        [self cycle3:ps i1:1 i2:5 i3:2];
        ps[2] ^= 1; ps[5] ^= 1;
    }
    else if (m == 2) {
        ps[8]++; if (ps[8] == 3) ps[8] = 0;
        [self cycle3:ps i1:0 i2:2 i3:4];
        ps[0] ^= 1; ps[2] ^= 1;
    }
    else if (m == 3) {
        ps[9]++; if (ps[9] == 3) ps[9] = 0;
        [self cycle3:ps i1:3 i2:4 i3:5];
        ps[3] ^= 1; ps[4] ^= 1;
    }
    q = 0;
    for (a = 9; a >= 6; a--) {
        q = q * 3 + ps[a];
    }
    for (a = 4; a >= 0; a--) {
        q = q * 2 + ps[a];
    }
    return q;
}

- (void) calcPyrm {
    for (int p = 0; p < 720; p++) {
        pPymPrun[p] = -1;
        for (int m = 0; m < 4; m++) {
            permPymmv[p][m] = [self getPymPermmv:p m:m];
        }
    }
    pPymPrun[0] = 0;
    for (int l = 0; l <= 6; l++) {
        int n = 0;
        for (int p = 0; p < 720; p++) {
            if (pPymPrun[p] == l) {
                for (int m = 0; m < 4; m++) {
                    int q = p;
                    for (int c = 0; c < 2; c++) {
                        q = permPymmv[q][m];
                        if (pPymPrun[q] == -1) {
                            pPymPrun[q] = l + 1;
                            n++;
                        }
                    }
                }
            }
        }
    }
    for (int p = 0; p < 2592; p++) {
        tPymPrun[p] = -1;
        for (int m = 0; m < 4; m++) {
            twstPymmv[p][m] = [self getPymTwsmv:p m:m];
        }
    }
    tPymPrun[0] = 0;
    for (int l = 0; l <= 5; l++) {
        int n = 0;
        for (int p = 0; p < 2592; p++) {
            if (tPymPrun[p] == l) {
                for (int m = 0; m < 4; m++) {
                    int q = p;
                    for (int c = 0; c < 2; c++) {
                        q = twstPymmv[q][m];
                        if (tPymPrun[q] == -1) {
                            tPymPrun[q] = l + 1;
                            n++;
                        }
                    }
                }
            }
        }
    }
}

- (Pyraminx *)init {
    if (self = [super init]) {
        [self calcPyrm];
        facePym = [[NSArray alloc] initWithObjects:@"U", @"L", @"R", @"B", nil];
        sufPym = [[NSArray alloc] initWithObjects:@"'", @"", nil];
        tipsPym = [[NSArray alloc] initWithObjects:@"l", @"r", @"b", @"u", nil];
        srand((unsigned)time(0));
    }
    return self;
}

- (void) initPymBrd {
    for (int i = 0; i< 9; i++) {
        posit[i]=0;
        posit[i+9]=1;
        posit[i+18]=2;
        posit[i+27]=3;
    }
}

- (BOOL) searchPym: (int)q t:(int)t l:(int)l lm:(int)lm{
    if (l == 0) return q == 0 && t == 0;
    if (pPymPrun[q] > l || tPymPrun[t] > l) return false;
    int p, s, a, m;
    for (m = 0; m < 4; m++) {
        if (m != lm) {
            p = q;
            s = t;
            for (a = 0; a < 2; a++) {
                p = permPymmv[p][m];
                s = twstPymmv[s][m];
                if ([self searchPym:p t:s l:(l-1) lm:m]) {
                    solPym[l]=m<<1|a;
                    return true;
                }
            }
        }
    } 
    return false;
}

- (void) dosolvePym {
    int t = 0; int q = 0; BOOL parity = NO;
    int pcperm[] = {0, 1, 2, 3, 4, 5, 6};
    for (int i = 0; i < 4; i++) {
        int other = i + rand() % (6 - i);
        int temp = pcperm[i];
        pcperm[i] = pcperm[other];
        pcperm[other] = temp;
        if (i != other) parity = !parity;
    }
    if (parity) {
        int temp = pcperm[4];
        pcperm[4] = pcperm[5];
        pcperm[5] = temp;
    }
    parity = NO;
    int pcori[10];
    for (int i = 0; i < 5; i++) {
        pcori[i] = rand() % 2;
        if (pcori[i] == 1) parity = !parity;
    }
    if (parity == YES) {
        pcori[5] = 1;
    } else {
        pcori[5] = 0;
    }
    //pcori[5] = (parity ? YES : NO);
    for (int i = 6; i < 10; i++) {
        pcori[i] = rand() % 3;
    }
    for (int a = 0; a < 6; a++) {
        int b = 0;
        for (int c = 0; c < 6; c++) {
            if (pcperm[c] == a) break;
            if (pcperm[c] > a) b++;
        }
        q = q * (6 - a) + b;
    }
    for (int a = 9; a >= 6; a--) {
        t = t * 3 + pcori[a];
    }
    for (int a = 4; a >= 0; a--) {
        t = t * 2 + pcori[a];
    }
    if (q != 0 || t != 0) {
        for (int l = 0; l < 12; l++) {
            if ([self searchPym:q t:t l:l lm:-1]) {
                sollen = l;
                break;
            }
        }
    }
}

- (NSString *)scrPyrm {
    [self initPymBrd];
    [self dosolvePym];
    
    NSMutableString *scramble = [NSMutableString string];
    for (int i = 1; i <= sollen; i++) {
        [scramble appendFormat:@"%@%@ ", [facePym objectAtIndex:(solPym[i]>>1)], [sufPym objectAtIndex:(solPym[i]&1)]];
    }
    for (int i = 0; i < 4; i++) {
        int j = rand() % 3;
        if (j < 2) 
            [scramble appendFormat:@"%@%@ ", [tipsPym objectAtIndex:i], [sufPym objectAtIndex:j]];
    }
    return scramble;
}

@end
