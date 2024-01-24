/* CLEANING DATA IN SQL QUERIRES */
-- GOAL IS TO CLEAN THE DATA AND MAKE IT MORE USABLE
SELECT * 
FROM PortfolioProject1..NashvilleHousing
--------------------------------------------------
---- STANDARDIZE DATE FORMAT

SELECT SaleDate, convert(Date, SaleDate)
FROM PortfolioProject1.[dbo].[NashvilleHousing]

-- UPDATE NashvilleHousing
-- SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject1.dbo.NashvilleHousing

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing


---------------------------------------------------
---- POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

-- SINCE THERE ARE NULL VALUES WE WANT TO POPULATE THE PROPERTY ADDRESS BASED ON PARCEL ID
SELECT housa.ParcelID, housa.PropertyAddress, housb.ParcelID, housb.PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing housa
JOIN PortfolioProject1.dbo.NashvilleHousing housb
	ON housa.ParcelID = housb.ParcelID
	AND housa.[UniqueID] <> housb.[UniqueID]
WHERE housa.PropertyAddress IS NULL

SELECT housa.ParcelID, housa.PropertyAddress, housb.ParcelID, housb.PropertyAddress, ISNULL(housa.PropertyAddress,housb.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing housa
JOIN PortfolioProject1.dbo.NashvilleHousing housb
	ON housa.ParcelID = housb.ParcelID
	AND housa.[UniqueID] <> housb.[UniqueID]
WHERE housa.PropertyAddress IS NULL

---- UPDATE THE VALUES IN PROPERTY ADDRESS THAT ARE NULL 
UPDATE housa
SET PropertyAddress = ISNULL(housa.PropertyAddress,housb.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing housa
JOIN PortfolioProject1.dbo.NashvilleHousing housb
	ON housa.ParcelID = housb.ParcelID
	AND housa.[UniqueID] <> housb.[UniqueID]
WHERE housa.PropertyAddress IS NULL

---- TO VERIFY THAT THERE ARE NO NULL VALUES IN  PROPERTY ADDRESS
SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
---------------------------------------------------
---- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address --CHARINDEX is to look for characters
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address 
FROM PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

-- use parsename

SELECT
PARSENAME( REPLACE(OwnerAddress, ',','.'), 1)
, PARSENAME( REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME( REPLACE(OwnerAddress, ',','.'), 3)
FROM NashvilleHousing

SELECT
PARSENAME( REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME( REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME( REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing




-- ADD THE NEW VALUES
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',','.'), 3) 


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',','.'), 1)




SELECT *
FROM NashvilleHousing

--SELECT OwnerAddress
--FROM NashvilleHousing
----------------------------------------------------
---- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT"

SELECT Distinct(SoldAsVacant)
FROM NashvilleHousing

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant,
CASE	WHEN SoldAsVacant =	1 THEN 'Yes'
		WHEN SoldAsVacant = 0 THEN 'No'
		ELSE CAST(SoldAsVacant AS VARCHAR(5)) 
		END AS SoldVacantText
FROM PortfolioProject1.dbo.NashvilleHousing

-- add another column WITH SOLDASVACANT AS TEXT

ALTER TABLE NashvilleHousing
ADD SoldAsVacantString NVARCHAR(5);

UPDATE NashvilleHousing
SET SoldAsVacantString = IIF(SoldAsVacant = 1, 'Yes', 'No')

SELECT *
FROM NashvilleHousing

-----------------------------------------
---- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---- EXPLANATION OF THE QUERY ABOVE:
    --Common Table Expression (CTE):
    --    The query starts with the declaration of a CTE named RowNumCTE.
    --    A CTE is a named temporary result set that you can reference within the context of a SELECT, INSERT, UPDATE, or DELETE statement.

    --ROW_NUMBER() Window Function:
    --    The ROW_NUMBER() function assigns a unique sequential integer to each row within the result set based on the specified ordering.
    --    The ORDER BY UniqueID part ensures that the row numbers are assigned based on the order of the UniqueID column.

    --PARTITION BY Clause:
    --    The PARTITION BY clause is used to divide the result set into partitions based on specific columns.
    --    In this case, the result set is partitioned by ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference.
    --    The ROW_NUMBER() function restarts numbering for each partition.

    --Resulting Output:
    --    The result set includes all columns from the NashvilleHousing table.
    --    The row_num column represents the sequential row number within each partition, based on the specified ordering.


------- TO DELETE THE DUPLICATES:


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

Select *
FROM RowNumCTE
WHERE row_num > 1


----------------------------------------------------
---- DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

