-- Creating a table
CREATE TABLE NASHVILLEHOUSING (
    UniqueID INT PRIMARY KEY,
    ParcelID VARCHAR(255),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255), 
    SaleDate DATE,
    SalePrice DECIMAL(12, 2),	
    LegalReference VARCHAR(255), 
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(5, 2),	
    TaxDistrict VARCHAR(50),
    LandValue DECIMAL(12, 2),
    BuildingValue DECIMAL(12, 2),
    TotalValue DECIMAL(12, 2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-- Checking if data in imported correctly
SELECT  SALEDATE
FROM NASHVILLEHOUSING


-- populate property address data
-- there are few values which is NULL is propertyaddress field
-- so in this query below we have joined the same table on the basis of parcel id as we figured out that uniqueid with same parcel id has same address 
SELECT a.parcelid, b.parcelid, a.propertyaddress, b.propertyaddress,
       COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashvillehousing a
     JOIN nashvillehousing b 
	 ON a.Parcelid = b.Parcelid
	 AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress ISNULL	 

-- used COALESCE fn to fill the null values with the address of same parcel id
-- used update fn to update the database
UPDATE nashvillehousing AS a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing AS b
WHERE a.parcelid = b.parcelid
  AND a.uniqueid <> b.uniqueid
  AND a.propertyaddress IS NULL;

-- Checking if the PROPERTYADDRESS is updated
SELECT propertyaddress
FROM nashvillehousing
WHERE propertyaddress is NULL


-- Breaking Address into individual columns (address,city,state)
SELECT 
    SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1) AS address,
    SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1 FOR LENGTH(propertyaddress)) AS CITY_NAME
FROM nashvillehousing;

-- Inserting new column to store the split address
ALTER TABLE nashvillehousing
ADD COLUMN address TEXT,
ADD COLUMN city_name TEXT;


UPDATE nashvillehousing AS a
SET
   Address=SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1),
   city_name=SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1 FOR LENGTH(propertyaddress)) 
WHERE POSITION(','IN propertyaddress)>0  

-- Breaking owners address into individual columns (address city state)
SELECT 
    SPLIT_PART(owneraddress, ',', 1) AS street_address,
    SPLIT_PART(owneraddress, ',', 2) AS city,
    SPLIT_PART(owneraddress, ',', 3) AS state
FROM nashvillehousing;


ALTER TABLE nashvillehousing
ADD COLUMN street_address TEXT,
ADD COLUMN city TEXT,
ADD COLUMN state TEXT;


UPDATE nashvillehousing
SET 
    street_address = SPLIT_PART(owneraddress, ',', 1),
    city = TRIM(SPLIT_PART(owneraddress, ',', 2)),
    state = TRIM(SPLIT_PART(owneraddress, ',', 3));


-- replacing Y&N with yes or no in the column name soldasvacant
-- Checking if there is any Y AND N in the column soldasvacant
SELECT DISTINCT(soldasvacant)
FROM nashvillehousing

SELECT soldasvacant,
       CASE 
           WHEN soldasvacant = 'Y' THEN 'YES'
           WHEN soldasvacant = 'N' THEN 'NO'
           ELSE soldasvacant
       END AS sold_as_vacant_status
FROM Nashvillehousing;
   
       
UPDATE nashvillehousing AS a
SET Soldasvacant=
   CASE 
        WHEN soldasvacant = 'Y' THEN 'YES'
        WHEN soldasvacant = 'N' THEN 'NO'
        ELSE soldasvacant
       END 

-- REMOVING DUPLICATES
WITH DuplicateCTE AS (
    SELECT 
        uniqueid,
        ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, legalreference ORDER BY uniqueid) AS row_num
    FROM nashvillehousing
)
DELETE FROM nashvillehousing
WHERE uniqueid IN (
    SELECT uniqueid
    FROM DuplicateCTE
    WHERE row_num > 1
);

-- delete unused columns
ALTER TABLE nashvillehousing 
DROP COLUMN owneraddress,
DROP COLUMN propertyaddress,
DROP COLUMN taxdistrict,
DROP COLUMN landuse,
DROP COLUMN saledate;

-- Checking if the column is dropped
SELECT *
FROM nashvillehousing
			
