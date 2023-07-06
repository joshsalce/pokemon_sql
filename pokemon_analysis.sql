DROP DATABASE IF EXISTS Pokemon_Data;
CREATE DATABASE  `Pokemon_Data` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_cs ;
USE `Pokemon_Data`;

/* Query ALL pokemon */
SELECT * FROM pokemon ORDER BY Number ASC;

/* Get all Distinct Types (Single and Dual-Type) 
Ones left out: 
	Normal-Ice, Normal-Bug, Normal-Bug, Normal-Steel, Fire-Fairy, 
	Ice-Poison, Ground-Fairy, Bug-Dragon, Rock-Ghost
*/
SELECT Type_1, Type_2 From pokemon GROUP BY Type_1, Type_2;

/* Get all dual-type Pokemon */
SELECT * FROM pokemon WHERE Type_2 IS NOT NULL ORDER BY Number;

/* Add weaknesses to Type_1 For each pokemon*/
SELECT DISTINCT Type_1 FROM pokemon;


/* Calculate Normalized Values for Pokemon Stats Across All Pokemon Not Mega-Evolved*/
SET @Avg_HP := (SELECT ROUND(AVG(HP)) FROM pokemon);
SET @Avg_Atk := (SELECT ROUND(AVG(Attack)) FROM pokemon);
SET @Avg_Def := (SELECT ROUND(AVG(Defense)) FROM pokemon);
SET @Avg_SpAtk := (SELECT ROUND(AVG(Sp_Atk)) FROM pokemon);
SET @Avg_SpDef := (SELECT ROUND(AVG(Sp_Def)) FROM pokemon);
SET @Avg_Speed := (SELECT ROUND(AVG(Speed)) FROM pokemon);

SELECT Number, Name, Generation, Type_1, Type_2, ROUND((HP / @Avg_HP) * 100 ) AS HP_plus,
ROUND((Attack / @Avg_Atk) * 100 ) AS Atk_plus,
ROUND((Defense / @Avg_Def) * 100 ) AS Def_plus,
ROUND((Sp_Atk / @Avg_SpAtk) * 100 ) AS SpAtk_plus,
ROUND((Sp_Def / @Avg_SpDef) * 100 ) AS SpDef_plus,
ROUND((Speed / @Avg_Speed) * 100 ) AS Speed_plus
FROM pokemon 
WHERE NAME NOT LIKE '%Mega%'
ORDER BY Number ASC;

/* Get Average HP for Generations of Pokemon */
SELECT Generation, ROUND(AVG(HP)) AS Avg_HP FROM pokemon GROUP BY Generation ORDER BY Generation;

/* Get Number of Pokemon per Generation */
 SELECT Generation, COUNT(Number) FROM pokemon GROUP BY Generation; 


/* Find Types with Most Weaknesses */
SELECT Type_1, Type_2, COUNT(id) AS Num_Weaknesses FROM eaknesses GROUP BY Type_1, Type_2 ORDER BY Num_Weaknesses DESC;

/* Find Types with Least Weaknesses */
SELECT Type_1, Type_2, COUNT(id) AS Num_Weaknesses FROM weaknesses GROUP BY Type_1, Type_2 ORDER BY Num_Weaknesses;

/* Query for Pokemon with a type that matches one of the types of their weaknesses*/
SELECT Name, a.Type_1, a.Type_2, b.Weakness FROM pokemon a
JOIN weaknesses b ON a.Type_1 = b.Type_1 AND a.Type_2 = b.Type_2
WHERE a.Type_1 = b.Weakness OR a.Type_2 = b.Weakness
ORDER BY Name;

/* Find Types with Most Strengths */
SELECT Type_1, Type_2, COUNT(id) AS Num_Strengths FROM strengths GROUP BY Type_1, Type_2 ORDER BY Num_Strengths DESC;

/* Find Types with Least Strengths */
SELECT Type_1, Type_2, COUNT(id) AS Num_Strengths FROM strengths GROUP BY Type_1, Type_2 ORDER BY Num_Strengths;

/* Query for Pokemon with a type that matches one of the types they're super effective against*/
SELECT Name, a.Type_1, a.Type_2, b.Strength FROM pokemon a
JOIN strengths b ON a.Type_1 = b.Type_1 AND a.Type_2 = b.Type_2
WHERE a.Type_1 = b.Strength OR a.Type_2 = b.Strength
ORDER BY Name;


/* Query for Pokemon's number of weaknesses and strengths (Two joins) */
SELECT a.Name, a.Generation, a.Type_1, a.Type_2, b.Num_Weaknesses, c.Num_Strengths FROM pokemon a 
JOIN (SELECT Type_1, Type_2, COUNT(id) AS Num_Weaknesses FROM weaknesses GROUP BY Type_1, Type_2) b 
ON (a.Type_1 = b.Type_1 AND a.Type_2 = b.Type_2) OR (a.Type_1 = b.Type_2 AND a.Type_2 = b.Type_1)
JOIN (SELECT Type_1, Type_2, COUNT(id) AS Num_Strengths FROM strengths GROUP BY Type_1, Type_2) c
ON (a.Type_1 = c.Type_1 AND a.Type_2 = c.Type_2) OR (a.Type_1 = c.Type_2 AND a.Type_2 = c.Type_1)
ORDER BY Number;


/* Concatenate all weaknesses into one column, show for all FireRed, LeafGreen (Gen. 1) Pokemon */
SELECT pokemon.Number, pokemon.Name, pokemon.Type_1, pokemon.Type_2,
COUNT(DISTINCT b.Weakness) + COUNT(DISTINCT c.Weakness) AS Num_Weaknesses,
CONCAT(COALESCE(GROUP_CONCAT(DISTINCT b.Weakness SEPARATOR ', '), ''), COALESCE(GROUP_CONCAT(DISTINCT c.Weakness SEPARATOR ', '),'')) as Weaknesses,
COUNT(DISTINCT d.Strength) AS Num_Strengths,
COALESCE(GROUP_CONCAT(DISTINCT d.Strength SEPARATOR ', '), '') as Strengths 
FROM pokemon 
LEFT JOIN dual_weaknesses b 
ON (pokemon.Type_1 = b.Type_1 AND pokemon.Type_2 = b.Type_2) OR (pokemon.Type_1 = b.Type_2 AND pokemon.Type_2 = b.Type_1) 
LEFT JOIN single_weaknesses c 
ON (pokemon.Type_1 = c.Type_1) AND pokemon.Type_2 IS NULL
LEFT JOIN single_strengths d
ON pokemon.Type_1 = d.Type_1 OR pokemon.Type_2 = d.Type_1
WHERE Generation = 1 AND NAME NOT LIKE '%Mega%'
GROUP BY pokemon.Name
ORDER BY pokemon.Number;



