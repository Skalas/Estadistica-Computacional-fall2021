/*

* ITAM-Data - Product Architecture - Master Liliana Millán

* Project: Chicago Food Inspections - Team 05

* Script: Create CFI dabase...

*/

DROP TABLE IF EXISTS variables;
CREATE TABLE variables (
    MOPLLAAG int,
    MINK123M int, 
    PPERSAUT int,
    PWAOREG int,
    PBRAND int,
    APLEZIER int,
    AFIETS int,
    CARAVAN int
);

INSERT INTO variables (MOPLLAAG, MINK123M, PPERSAUT, PWAOREG, PBRAND, APLEZIER, AFIETS, CARAVAN) VALUES (0,1,0,0,0,1,0,1);
