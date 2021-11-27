//
//  Util.h
//  DCTimer Scrambles
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

#import <Foundation/Foundation.h>
#import "CubieCube.h"

@interface Util : NSObject
+(void)toCubieCube:(int[])f cc:(CubieCube *)ccRet;
+(NSString *)toFaceCube:(CubieCube *)cc;
+(void)set8Perm:(int[])arr i:(int)idx;
+(int)get8Perm:(int[])arr;
+(int) binarySearch:(unsigned short[])arr l:(int)length k:(int)key;
+(int) getNParity:(int)idx n:(int)n;
+(int) getNPerm:(int[])arr n:(int)n;
+(void) setNPerm:(int[])arr i:(int)idx n:(int)n;
+(int) getComb:(int[])arr m:(int)mask;
+(void) setComb:(int[])arr i:(int)idx m:(int)mask;
+(void) setupUtil;
@end
