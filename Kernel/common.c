
#include "common.h"

void * __cdecl memmove (
        void * dst,
        const void * src,
        size_t count
        )
{
    void * ret = dst;

    if (dst <= src || (char *)dst >= ((char *)src + count))
    {
        /*
        * Non-Overlapping Buffers
        * copy from lower addresses to higher addresses
        */
        while (count--) {
            *(char *)dst = *(char *)src;
            dst = (char *)dst + 1;
            src = (char *)src + 1;
        }
    }
    else
    {
        /*
        * Overlapping Buffers
        * copy from higher addresses to lower addresses
        */
        dst = (char *)dst + count - 1;
        src = (char *)src + count - 1;

        while (count--) {
            *(char *)dst = *(char *)src;
            dst = (char *)dst - 1;
            src = (char *)src - 1;
        }
    }

    return(ret);
}