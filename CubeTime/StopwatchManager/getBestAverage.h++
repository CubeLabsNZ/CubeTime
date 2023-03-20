#ifndef getBestAverage_h
#define getBestAverage_h

#ifdef __cplusplus
extern "C" {
#endif
double getBestAverageOf(const int width,
                        const int trim,
                        const int solvesCount,
                        
                        const double solves[_Nonnull],
                        
                        int countedSolvesIndices[_Nonnull],
                        int trimmedSolvesIndices[_Nonnull]);
#ifdef __cplusplus
}
#endif

#endif /* getBestAverage_h */
