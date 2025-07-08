-- 1. Rename columns
ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

-- 2. Set NOT NULL on melting/boiling point
ALTER TABLE properties
ALTER COLUMN melting_point_celsius SET NOT NULL,
ALTER COLUMN boiling_point_celsius SET NOT NULL;

-- 3. Set UNIQUE and NOT NULL on symbol and name
ALTER TABLE elements
ALTER COLUMN symbol SET NOT NULL,
ALTER COLUMN name SET NOT NULL;

ALTER TABLE elements
ADD CONSTRAINT unique_symbol UNIQUE(symbol),
ADD CONSTRAINT unique_name UNIQUE(name);

-- 4. Set atomic_number in properties as foreign key
ALTER TABLE properties
ADD CONSTRAINT fk_atomic_number
FOREIGN KEY (atomic_number) REFERENCES elements(atomic_number);

-- 5. Create types table
CREATE TABLE types (
  type_id SERIAL PRIMARY KEY,
  type VARCHAR NOT NULL
);

-- 6. Insert 3 types from existing data
INSERT INTO types(type)
SELECT DISTINCT type
FROM properties
WHERE type IS NOT NULL;

-- 7. Add type_id column to properties
ALTER TABLE properties
ADD COLUMN type_id INT;

-- 8. Update type_id based on types table
UPDATE properties
SET type_id = (
  SELECT type_id FROM types
  WHERE types.type = properties.type
);

-- 9. Set NOT NULL and foreign key on type_id
ALTER TABLE properties
ALTER COLUMN type_id SET NOT NULL;

ALTER TABLE properties
ADD CONSTRAINT fk_type_id
FOREIGN KEY (type_id) REFERENCES types(type_id);

-- 10. Capitalize first letter of symbol in elements
UPDATE elements
SET symbol = UPPER(LEFT(symbol, 1)) || SUBSTRING(symbol FROM 2);

-- 11. Remove trailing zeros from atomic_mass
ALTER TABLE properties
ALTER COLUMN atomic_mass TYPE DECIMAL(10,5);

-- 12. Insert Fluorine (atomic_number 9)
INSERT INTO elements(atomic_number, name, symbol)
VALUES (9, 'Fluorine', 'F');

INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
VALUES (
  9, 18.998, -220, -188.1,
  (SELECT type_id FROM types WHERE type='nonmetal')
);

-- 13. Insert Neon (atomic_number 10)
INSERT INTO elements(atomic_number, name, symbol)
VALUES (10, 'Neon', 'Ne');

INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
VALUES (
  10, 20.18, -248.6, -246.1,
  (SELECT type_id FROM types WHERE type='nonmetal')
);
