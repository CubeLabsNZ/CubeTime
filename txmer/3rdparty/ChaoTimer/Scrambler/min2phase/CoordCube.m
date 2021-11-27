//
//  CoordCube.m
//  DCTimer Scramblers
//
//  Adapted from Shuang Chen's min2phase implementation of the Kociemba algorithm, as obtained from https://github.com/ChenShuang/min2phase
//
//  Copyright (c) 2013, Shuang Chen
//  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the creator nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "CoordCube.h"
#import "CubieCube.h"

@implementation CoordCube
static const int N_MOVES = 18;
static const int N_MOVES2 = 10;

static const int N_SLICE = 495;
static const int N_TWIST_SYM = 324;
static const int N_FLIP_SYM = 336;
static const int N_PERM_SYM = 2768;
static const int N_MPERM = 24;

extern int SymInv[];
extern int permMult[24][24];
extern unsigned short FlipS2R[];
extern unsigned short TwistS2R[];
extern unsigned short EPermS2R[];
extern int ud2std[];
extern int SymInv[16];
extern int SymMult[16][16];
//extern int SymMove[16][18];
extern int Sym8Mult[8][8];
extern int Sym8Move[8][18];
extern int SymMultInv[8][8];
extern int SymMoveUD[16][10];
extern int Sym8MultInv[8][8];
extern unsigned short SymStateTwist[324];
extern unsigned short SymStateFlip[336];
extern unsigned short SymStatePerm[2768];
extern int e2c[];

//XMove = Move Table
//XPrun = Pruning Table
//XConj = Conjugate Table

//phase1
unsigned short UDSliceMove[N_SLICE][N_MOVES];
unsigned short TwistMove[N_TWIST_SYM][N_MOVES];
unsigned short FlipMove[N_FLIP_SYM][N_MOVES];
unsigned short UDSliceConj[N_SLICE][8];
int UDSliceTwistPrun[N_SLICE * N_TWIST_SYM / 8 + 1];
int UDSliceFlipPrun[N_SLICE * N_FLIP_SYM / 8];
//int TwistFlipPrun[N_FLIP_SYM * N_TWIST_SYM * 8 / 8]; //Using TWIST_FLIP_PRUN

//phase2
unsigned short CPermMove[N_PERM_SYM][N_MOVES];
unsigned short EPermMove[N_PERM_SYM][N_MOVES2];
unsigned short MPermMove[N_MPERM][N_MOVES2];
unsigned short MPermConj[N_MPERM][16];
int MCPermPrun[N_MPERM * N_PERM_SYM / 8];
int MEPermPrun[N_MPERM * N_PERM_SYM / 8];

+(void) setPruning:(int[])table i:(int)index v:(int)value {
    table[index >> 3] ^= (0x0f ^ value) << ((index & 7) << 2);
}

+(int) getPruning:(int[])table i:(int)index {
    return (table[index >> 3] >> ((index & 7) << 2)) & 0x0f;
}

+(void) initUDSliceMoveConj {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_SLICE; i++) {
        [c setUDSlice:i];
        for (int j=0; j<N_MOVES; j+=3) {
            [CubieCube EdgeMult:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            UDSliceMove[i][j] = [d getUDSlice];
        }
        for (int j=0; j<16; j+=2) {
            [CubieCube EdgeConjugate:c idx:SymInv[j] cubeB:d];
            UDSliceConj[i][(j >> 1)] = [d getUDSlice] & 0x1ff;
        }
    }
    for (int i=0; i<N_SLICE; i++) {
        for (int j=0; j<N_MOVES; j+=3) {
            int udslice = UDSliceMove[i][j];
            for (int k=1; k<3; k++) {
                int cx = UDSliceMove[udslice & 0x1ff][j];
                udslice = permMult[udslice>>9][cx>>9]<<9|(cx&0x1ff);
                UDSliceMove[i][j+k] = udslice;
            }
        }
    }
}

+(void) initFlipMove {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_FLIP_SYM; i++) {
        [c setFlip:FlipS2R[i]];
        for (int j=0; j<N_MOVES; j++) {
            [CubieCube EdgeMult:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            FlipMove[i][j] = [d getFlipSym];
        }
    }
}

+(void) initTwistMove {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_TWIST_SYM; i++) {
        [c setTwist:TwistS2R[i]];
        for (int j=0; j<N_MOVES; j++) {
            [CubieCube CornMult:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            TwistMove[i][j] = [d getTwistSym];
        }
    }
}

+(void) initCPermMove {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_PERM_SYM; i++) {
        [c setCPerm:EPermS2R[i]];
        for (int j=0; j<N_MOVES; j++) {
            [CubieCube CornMult:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            CPermMove[i][j] = [d getCPermSym];
        }
    }
}

+(void) initEPermMove {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_PERM_SYM; i++) {
        [c setEPerm: EPermS2R[i]];
        for (int j=0; j<N_MOVES2; j++) {
            [CubieCube EdgeMult:c cubeB:[[CubieCube moveCube] objectAtIndex:ud2std[j]] cubeProd:d];
            EPermMove[i][j] = [d getEPermSym];
        }
    }
}

+(void) initMPermMoveConj {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_MPERM; i++) {
        [c setMPerm:i];
        for (int j=0; j<N_MOVES2; j++) {
            [CubieCube EdgeMult:c cubeB:[[CubieCube moveCube] objectAtIndex:ud2std[j]] cubeProd:d];
            MPermMove[i][j] = [d getMPerm];
        }
        for (int j=0; j<16; j++) {
            [CubieCube EdgeConjugate:c idx:SymInv[j] cubeB:d];
            MPermConj[i][j] = [d getMPerm];
        }
    }
}

+(void) initRawSymPrun:(int[])PrunTable id:(int)INV_DEPTH
                    rm:(unsigned short*)RawMove rc:(unsigned short*)RawConj
                    sm:(unsigned short *)SymMove ss:(unsigned short*)SymState
                   ssw:(int*)SymSwitch mm:(int*)moveMap ssh:(int)SYM_SHIFT
                    nr:(int)N_RAW ns:(int)N_SYM nm:(int) N_MOVES nsy:(int)N_SYMMOVES rcs:(int)RawConjSize {
    int SYM_MASK = (1 << SYM_SHIFT) - 1;
    int N_SIZE = N_RAW * N_SYM;
    
    for (int i=0; i<(N_RAW*N_SYM+7)/8; i++) {
        PrunTable[i] = -1;
    }
    [CoordCube setPruning:PrunTable i:0 v:0];
    
    int depth = 0;
    int done = 1;
    
    while (done < N_SIZE) {
        BOOL inv = depth > INV_DEPTH;
        int select = inv ? 0x0f : depth;
        int check = inv ? depth : 0x0f;
        depth++;
        for (int i=0; i<N_SIZE;) {
            int val = PrunTable[i>>3];
            if (!inv && val == -1) {
                i += 8;
                continue;
            }
            for (int end=MIN(i+8, N_SIZE); i<end; i++, val>>=4) {
                if ((val & 0x0f)/*getPruning(PrunTable, i)*/ == select) {
                    int raw = i % N_RAW;
                    int sym = i / N_RAW;
                    for (int m=0; m<N_MOVES; m++) {
                        int index = (moveMap == NULL ? m : moveMap[m]);
                        int symx = SymMove[sym * N_SYMMOVES + index]; //Watch out for this
                        int rawIndex1 = RawMove[raw * N_MOVES + m] & 0x1ff;
                        int rawx = RawConj[rawIndex1 * RawConjSize + (symx & SYM_MASK)];
                        symx >>= (unsigned)SYM_SHIFT;
                        int idx = symx * N_RAW + rawx;
                        if ([CoordCube getPruning:PrunTable i:idx] == check) {
                            done++;
                            if (inv) {
                                [CoordCube setPruning:PrunTable i:i v:depth];
                                break;
                            } else {
                                [CoordCube setPruning:PrunTable i:idx v:depth];
                                for (int j=1, symState = SymState[symx]; (symState >>= 1) != 0; j++) {
                                    if ((symState & 1) == 1) {
                                        int idxx = symx * N_RAW + RawConj[rawx * RawConjSize + (j ^ (SymSwitch == NULL ? 0 : SymSwitch[j]))]; //Null?
                                        if ([CoordCube getPruning:PrunTable i:idxx] == 0x0f) {
                                            [CoordCube setPruning:PrunTable i:idxx v:depth];
                                            done++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //NSLog(@"%2d%8d", depth, done);
    }
}

+(void) initSliceTwistPrun {
    [CoordCube initRawSymPrun:UDSliceTwistPrun id:6
                           rm:(unsigned short*)UDSliceMove rc:(unsigned short*)UDSliceConj
                           sm:(unsigned short*)TwistMove ss:(unsigned short*)SymStateTwist
                          ssw:NULL mm:NULL ssh:3 nr:495 ns:324 nm:18 nsy:18 rcs:8];
}

+(void) initSliceFlipPrun {
    [CoordCube initRawSymPrun:UDSliceFlipPrun id:6
                           rm:(unsigned short*)UDSliceMove rc:(unsigned short*)UDSliceConj
                           sm:(unsigned short*)FlipMove ss:(unsigned short*)SymStateFlip
                          ssw:NULL mm:NULL ssh:3 nr:495 ns:336 nm:18 nsy:18 rcs:8];
}

+(void) initMEPermPrun {
    [CoordCube initRawSymPrun:MEPermPrun id:7
                           rm:(unsigned short*)MPermMove rc:(unsigned short*)MPermConj
                           sm:(unsigned short*)EPermMove ss:(unsigned short*)SymStatePerm
                          ssw:NULL mm:NULL ssh:4 nr:24 ns:2768 nm:10 nsy:10 rcs:16];
}

+(void) initMCPermPrun {
    [CoordCube initRawSymPrun:MCPermPrun id:10
                           rm:(unsigned short*)MPermMove rc:(unsigned short*)MPermConj
                           sm:(unsigned short*)CPermMove ss:(unsigned short*)SymStatePerm
                          ssw:e2c mm:ud2std ssh:4 nr:24 ns:2768 nm:10 nsy:18 rcs:16];
}
@end
