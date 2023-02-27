#include <map>
#include <vector>
#include "getBestAverage.h++"
#include <cmath>
#include <numeric>

#define DINF std::numeric_limits<double>::infinity()

#include <iostream>

using namespace std;

extern "C" {
double getBestAverageOf(const int width,
                        const int trim,
                        const int solvesCount,
                        
                        const double solves[_Nonnull],
                        
                        int countedSolvesIndices[_Nonnull],
                        int trimmedSolvesIndices[_Nonnull]) {
    
    if (solvesCount < width) return NAN;
    
    multimap<double, int> s;
    double best = DINF;
    double sum = 0;
    double trimSum = 0;
    
    
    for (int i = 0; i < width - 1; i++) {
        if (solves[i] != DINF)
            sum += solves[i];
        s.emplace(solves[i], i);
    }
    
    
    for (int i = width - 1; i < solvesCount; i++) {
        if (solves[i] != DINF)
            sum += solves[i];
        
        s.emplace(solves[i], i);
        
        auto minItr = s.begin();
        auto maxItr = --s.end();
        
        for (int i = 0; i < trim; ++i) {
            double tempMin, tempMax;
            if ((tempMin = (*(minItr++)).first) != DINF) trimSum += tempMin;
            if ((tempMax = (*(maxItr--)).first) != DINF) trimSum += tempMax;
        }

        
//        printf("itr itself: %f, dinf: %f, bool equal: %i", (*maxItr).first, DINF, (*maxItr).first == DINF);
        double curAvg = 0;
        if ((*maxItr).first == DINF) {
            curAvg = INFINITY;
        } else {
            curAvg = (double)(sum - trimSum) /(double) (width - 2*trim);
        }
       
        if (curAvg <= best) {
            auto minItr = s.begin(), maxItr = --s.end();
            for (int i = 0; i < trim; ++i) {
                trimmedSolvesIndices[2*i] = (*(minItr++)).second;
                trimmedSolvesIndices[2*i + 1] = (*(maxItr--)).second;
            }
            
            for (int i = 0; i < (width - trim*2); ++i)
                countedSolvesIndices[i] = (*(minItr++)).second;
            
            best = curAvg;
        }
        
        sum -= solves[i - width + 1];
        s.erase(s.find(solves[i - width + 1]));
        
        trimSum = 0;
    }
    
    return best;
}
}
