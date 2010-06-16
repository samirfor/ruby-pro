/* 
 * File:   date.c
 * Author: samir
 *
 * Created on 15 de Junho de 2010, 21:53
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#include "date.h"
#include "status.h"
#include "exceptions.h"

/*
 * Date module
 */

time_t form_parse_date(char *msg, char* input) {
    char do_again_flag;
    int day, month, year;
    struct tm time_info;
    time_t time;

    do {
        printf("%s", msg);
        do {
            do_again_flag = FALSE;
            printf("\tDia: ");
            read_string(input);
            if (!validate_number_int(input)) {
                do_again_flag = TRUE;
                continue;
            }
            day = atoi(input);
            if (day < 0 || day > 31) {
                do_again_flag = TRUE;
                printf(ERROR_MSG);
                continue;
            }
        } while (do_again_flag);
        do {
            do_again_flag = FALSE;
            printf("\tMes: ");
            read_string(input);
            if (!validate_number_int(input)) {
                do_again_flag = TRUE;
                continue;
            }
            month = atoi(input);
            if (month < 0 || month > 12) {
                do_again_flag = TRUE;
                printf(ERROR_MSG);
                continue;
            }
        } while (do_again_flag);
        do {
            do_again_flag = FALSE;
            printf("\tAno: ");
            read_string(input);
            if (!validate_number_int(input)) {
                do_again_flag = TRUE;
                continue;
            }
            year = atoi(input);
            if (year < 1900) {
                do_again_flag = TRUE;
                printf(ERROR_MSG);
                continue;
            }
        } while (do_again_flag);
        if (!validate_date(day, month, year)) {
            printf("%s: Data invalida.\n", __FILE__);
            do_again_flag = TRUE;
            continue;
        }

        // Parse para o formato time_t
        time_info.tm_year = year - 1900;
        time_info.tm_mon = month - 1;
        time_info.tm_mday = day;
        time_info.tm_hour = 0;
        time_info.tm_min = 0;
        time_info.tm_sec = 1;
        time_info.tm_isdst = 0;
        time = mktime(&time_info);
    } while (do_again_flag);
    return time;
}

time_t mkdate(int day, int month, int year) {
    struct tm time_info;
    time_t time = 0;

    // Parse para o formato time_t
    time_info.tm_year = year - 1900;
    time_info.tm_mon = month;
    time_info.tm_mday = day;
    time_info.tm_hour = 0;
    time_info.tm_min = 0;
    time_info.tm_sec = 1;
    time_info.tm_isdst = 0;
    time = mktime(&time_info);
    return time;
}

char * date_to_s(time_t *time) {
    char *buffer;
    struct tm *time_info;

    buffer = malloc(sizeof (char) * 11);
    if (!buffer) {
        printf(ALLOC_ERROR, __FILE__);
        exit(EXIT_FAILURE);
    }
    
    time_info = localtime(time);
    strftime(buffer, 11, "%d/%m/%Y", time_info);
    return buffer;
}
