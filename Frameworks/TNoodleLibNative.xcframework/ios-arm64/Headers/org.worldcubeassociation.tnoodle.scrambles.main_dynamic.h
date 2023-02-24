#ifndef __ORG_WORLDCUBEASSOCIATION_TNOODLE_SCRAMBLES_MAIN_H
#define __ORG_WORLDCUBEASSOCIATION_TNOODLE_SCRAMBLES_MAIN_H

#include <graal_isolate_dynamic.h>


#if defined(__cplusplus)
extern "C" {
#endif

typedef int (*run_main_fn_t)(int argc, char** argv);

typedef char* (*tnoodle_lib_scramble_fn_t)(graal_isolatethread_t*, int);

typedef char* (*tnoodle_lib_draw_scramble_fn_t)(graal_isolatethread_t*, int, const char*);

typedef void (*vmLocatorSymbol_fn_t)(graal_isolatethread_t* thread);

#if defined(__cplusplus)
}
#endif
#endif
