#include <map>
#include <vector>
#include "getBestAverage.h++"
#include <cmath>
#include <numeric>

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
    double best = 100;
    
    double sum = 0;
    
    for (int i = 0; i < solvesCount; i++) cout << solves[i] << " ";
    cout << endl;
    
    for (int i = 0; i < width - 1; i++) {
        sum += solves[i];
        s.emplace(solves[i], i);
    }
    
    double trimSum = 0;
    
    int trimmedSolvesSize = trim*2;
    int accountedSolvesSize = width - (trimmedSolvesSize);
        
    for (int i = width - 1; i < solvesCount; i++) {
        sum += solves[i];
        s.emplace(solves[i], i);
        
        auto minItr = s.begin();
        auto maxItr = --s.end();
        
        for (int i = 0; i < trim; ++i)
            trimSum += ((*(minItr++)).first + (*(maxItr--)).first);
        
        if ((*maxItr).first == INFINITY || (*maxItr).first == numeric_limits<double>::infinity()) return INFINITY;
        
        double avg = (double)(sum - trimSum) /(double) (width - 2*trim);
        
        if (avg < best) {
            auto minItr = s.begin(), maxItr = --s.end();
            for (int i = 0; i < trim; ++i) {
                trimmedSolvesIndices[2*i] = (*(minItr++)).second;
                trimmedSolvesIndices[2*i + 1] = (*(maxItr--)).second;
            }
            
            for (int i = 0; i < (width - trim*2); ++i)
                countedSolvesIndices[i] = (*(minItr++)).second;
            
            best = avg;
        }
        
        sum -= solves[i - width + 1];
        s.erase(s.find(solves[i - width + 1]));
        
        trimSum = 0;
    }
    
    return best;
}
}
