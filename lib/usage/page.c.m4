dnl
dnl lib/usage/page.c template.
dnl
dnl Copyright (C) 2010 Nikolai Kondrashov
dnl
dnl This file is part of hidrd.
dnl
dnl Hidrd is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl Hidrd is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with hidrd; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
dnl
dnl
include(`m4/hidrd/util.m4')dnl
dnl
`/** @file
 * @brief HID report descriptor - usage pages
 *
 * vim:nomodifiable
 *
 * ************* DO NOT EDIT ***************
 * This file is autogenerated from page.c.m4
 * *****************************************
 *
 * Copyright (C) 2009-2010 Nikolai Kondrashov
 *
 * This file is part of hidrd.
 *
 * Hidrd is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Hidrd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with hidrd; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * @author Nikolai Kondrashov <spbnick@gmail.com>
 *
 * @(#) $Id: page.c 103 2010-01-18 21:04:26Z spb_nick $
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "hidrd/usage/page.h"

'pushdef(`PAGE_SET',
`ifelse(eval(PAGE_SET_RANGE_NUM($1) > 1), 1,
bool
hidrd_usage_page_$1(hidrd_usage_page page)
{
PAGE_SET_RANGE_CHECK($1)
}

)')dnl
include(`db/usage/page_set.m4')dnl
popdef(`PAGE_SET')dnl
`
#if defined(HIDRD_WITH_TOKENS) || defined(HIDRD_WITH_NAMES)

typedef struct page_desc {
    hidrd_usage_page    page;
#ifdef HIDRD_WITH_TOKENS
    const char         *token;
#endif
#ifdef HIDRD_WITH_NAMES
    const char         *name;
#endif
} page_desc;

#ifdef HIDRD_WITH_TOKENS
#define PAGE_TOKEN(_token)  .token = _token,
#else
#define PAGE_TOKEN(_token)
#endif

#ifdef HIDRD_WITH_NAMES
#define PAGE_NAME(_name)    .name = _name,
#else
#define PAGE_NAME(_name)
#endif

static const page_desc desc_list[] = {

#define PAGE(_TOKEN, _token, _name) \
    {.page = HIDRD_USAGE_PAGE_##_TOKEN,     \
     PAGE_TOKEN(#_token) PAGE_NAME(_name)}

    PAGE(UNDEFINED, undefined, "undefined"),

'dnl
define(`PAGE', `    `PAGE'(translit($2, a-z, A-Z), $2, "$3"),')dnl
include(`db/usage/page.m4')dnl
`
#undef PAGE

    {.page  = HIDRD_USAGE_PAGE_INVALID,
     PAGE_TOKEN(NULL) PAGE_NAME(NULL)}
};

#undef PAGE_NAME
#undef PAGE_TOKEN


static const page_desc *
lookup_desc_by_id(hidrd_usage_page page)
{
    const page_desc    *desc;

    assert(hidrd_usage_page_valid(page));

    for (desc = desc_list; desc->page != HIDRD_USAGE_PAGE_INVALID; desc++)
        if (desc->page == page)
            return desc;

    return NULL;
}


#ifdef HIDRD_WITH_TOKENS

char *
hidrd_usage_page_to_token(hidrd_usage_page page)
{
    const page_desc    *desc;
    char               *token;

    assert(hidrd_usage_page_valid(page));
    desc = lookup_desc_by_id(page);

    if (desc != NULL)
        return strdup(desc->token);
    else if (asprintf(&token, "%X", page) > 0)
        return token;

    return NULL;
}


hidrd_usage_page
hidrd_usage_page_from_token(const char *token)
{
    const page_desc    *desc;
    hidrd_usage_page    page;

    for (desc = desc_list; desc->page != HIDRD_USAGE_PAGE_INVALID; desc++)
        if (strcasecmp(desc->token, token) == 0)
            return hidrd_usage_page_validate(desc->page);

    if (sscanf(token, "%X", &page) != 1)
        return HIDRD_USAGE_PAGE_INVALID;

    return page;
}

#endif /* HIDRD_WITH_TOKENS */

#ifdef HIDRD_WITH_NAMES

const char *
hidrd_usage_page_name(hidrd_usage_page page)
{
    const page_desc    *desc;

    assert(hidrd_usage_page_valid(page));

    desc = lookup_desc_by_id(page);

    return (desc != NULL) ? desc->name : NULL;
}

char *
hidrd_usage_page_desc(hidrd_usage_page page)
{
    char       *result      = NULL;
    char       *str         = NULL;
    char       *new_str     = NULL;
    const char *name;

    assert(hidrd_usage_page_valid(page));

    name = hidrd_usage_page_name(page);

    if (name == NULL)
        str = strdup("");
    else if (asprintf(&str, "%s", name) < 0)
        goto cleanup;

'changequote([,])[
#define MAP(_token, _name) \
    do {                                                    \
        if (!hidrd_usage_page_##_token(page))               \
            break;                                          \
                                                            \
        if (asprintf(&new_str,                              \
                     ((*str == '\0') ? "%s%s" : "%s, %s"),  \
                     str, _name) < 0)                       \
            goto cleanup;                                   \
                                                            \
        free(str);                                          \
        str = new_str;                                      \
        new_str = NULL;                                     \
    } while (0)
]changequote(`,')`

'pushdef(`PAGE_SET',
`    MAP($1, "$2");
')dnl
include(`db/usage/page_set.m4')dnl
popdef(`PAGE_SET')`
    result = str;
    str = NULL;

cleanup:

    free(new_str);
    free(str);

    return result;
}

#endif /* HIDRD_WITH_NAMES */

#endif /* defined HIDRD_WITH_TOKENS || defined HIDRD_WITH_NAMES */
'dnl
