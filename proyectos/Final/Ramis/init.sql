set timezone = 'America/Mexico_City';

create schema clean;

DROP TABLE IF EXISTS clean.variables;

CREATE TABLE clean.variables(
    mopllaag int,
    mink123m int,
    ppersaut int,
    pwaoreg int,
    pbrand int,
    aplezier int,
    afiets int,
    caravan int,
    date_ing timestamp with time zone
);

INSERT INTO clean.variables (mopllaag, mink123m, ppersaut, pwaoreg, pbrand, aplezier, afiets, caravan, date_ing) VALUES (0,1,0,0,0,1,0,1,CURRENT_TIMESTAMP);
