//
//  edf.h
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

#ifndef edf_h
#define edf_h

#include <stdint.h>

struct edf_header {
    char version[8];

    char local_patient_id[80];
    char local_recording_id[80];

    char start_date_of_recording[8]; // dd.mm.yy
    char start_time_of_recording[8]; // hh.mm.ss

    uint64_t header_record_size;

    char _reserved[44];

    char number_of_data_records[8]; // -1 if unknown
    char duration_of_data_record[8]; // [s]

    char number_of_signals[4];
};

#endif /* edf_h */
