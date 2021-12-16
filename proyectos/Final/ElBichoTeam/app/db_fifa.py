import psycopg2
import csv

conn = psycopg2.connect(f"postgresql://postgres:postgres@db:5432/postgres")
cur = conn.cursor()
cur.execute("""
    CREATE TABLE FIFA21(
    sofifa_id integer PRIMARY KEY,
    name text,
    age integer,
    height_cm integer,
    weight_kg integer,
    nationality text,
    club text,
    league text,
    overall  integer,
    value_eur integer,
    wage integer,
    position text,
    international_reputation integer,
    weak_foot integer,
    skill_moves integer,
    work_rate text,
    team_position text,
    team_jersey_nymber float,
    joined text,
    contract_valid float,
    pace text,
    shoooting text,
    passing text,
    dribbling text,
    defending text,
    physic text,
    attacking_crossing integer,
    attacking_heading integer,
    attacking_volleys integer,
    skill_curve integer,
    skill_fg integer,
    skill_long integer,
    movement_agility integer,
    movement_reactions integer,
    movement_balance integer,
    power_jumping integer,
    power_stamina integer,
    power_strength integer,
    mentality_aggression integer,
    mentality_vision integer,
    mentality_penalties integer,
    mentality_composure integer
)
""")

with open('fifa/datos_fifa21.csv', 'r') as f:
    # Notice that we don't need the `csv` module.
    next(f) # Skip the header row.
    cur.copy_from(f, 'FIFA21', sep=',')

conn.commit()
