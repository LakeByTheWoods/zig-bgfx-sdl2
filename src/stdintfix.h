#ifndef _STDINT_H
#define _STDINT_H	1

/* FIXME: This likely needs updating to support multiple operating systems */
/* FIXME: Ideally zig would be updated to special-case the troublesome macros */

/* Signed.  */
# define INT8_C(c)	c
# define INT16_C(c)	c
# define INT32_C(c)	c

#undef INT64_C
# if __WORDSIZE == 64
#  define INT64_C(c)	((long)c)
# else
#  define INT64_C(c)	((long long)c)
# endif

/* Unsigned.  */
# define UINT8_C(c)	c
# define UINT16_C(c)	c
#undef UINT32_C
#undef UINT64_C
# define UINT32_C(c)	((unsigned)c)
# if __WORDSIZE == 64
#  define UINT64_C(c)	((unsigned long)c)
# else
#  define UINT64_C(c)	((unsigned long long)c)
# endif

/* Maximal type.  */
#undef INTMAX_C
#undef UINTMAX_C
# if __WORDSIZE == 64
#  define INTMAX_C(c)	((long)c)
#  define UINTMAX_C(c)	((unsigned long)c)
# else
#  define INTMAX_C(c)	((long long)c)
#  define UINTMAX_C(c)	((unsigned long long)c)
# endif

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed short int int16_t;
typedef unsigned short int uint16_t;
typedef signed int int32_t;
typedef unsigned int uint32_t;
typedef signed long int int64_t;
typedef unsigned long int uint64_t;

typedef unsigned long int	uintptr_t;

typedef long int intmax_t;
typedef unsigned long int uintmax_t;

#endif
