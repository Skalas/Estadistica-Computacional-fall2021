create table users (id serial Primary key,
                    gender integer,
                    age integer,
                    hypertension integer,
                    heart_disease integer,
                    ever_married integer,                    
                    Residence_type integer,
                    avg_glucose_level numeric ,
                    bmi numeric ,
                    smoking_status integer,
                    stroke integer);

insert into users (gender,
                    age,
                    hypertension,
                    heart_disease,
                    ever_married,                    
                    Residence_type ,
                    avg_glucose_level,
                    bmi,
                    smoking_status,
                    stroke) values 
                    (1, 67, 0, 1, 1, 1, 228.69, 36.6, 2, 1);