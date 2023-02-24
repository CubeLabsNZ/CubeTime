#ifndef __ORG_WORLDCUBEASSOCIATION_TNOODLE_SCRAMBLES_MAIN_H
#define __ORG_WORLDCUBEASSOCIATION_TNOODLE_SCRAMBLES_MAIN_H

#include <graal_isolate.h>


#if defined(__cplusplus)
extern "C" {
#endif

int run_main(int argc, char** argv);

char* tnoodle_lib_scramble(graal_isolatethread_t*, int);

char* tnoodle_lib_draw_scramble(graal_isolatethread_t*, int, const char*);

void vmLocatorSymbol(graal_isolatethread_t* thread);

#if defined(__cplusplus)
}
#endif
#endif
