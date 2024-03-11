/*

Cleaning Data iin SQL Queries

*/

USE PortfolioProject

SELECT *
FROM [Nashville Housing Data for Data Cleaning]	

----------------------------------------------------------------------------------------------------
-- Standardized Sale Date (Date / Time Format)
-- Note: My Variation simply came as a Date format, this is for notes

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Nashville Housing Data for Data Cleaning]

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD SaleDateConverted Date;

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------
-- Populate Property Address Data

SELECT PropertyAddress
FROM [Nashville Housing Data for Data Cleaning]

SELECT *
FROM [Nashville Housing Data for Data Cleaning]
WHERE PropertyAddress IS NULL

SELECT *
FROM [Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]	
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]	
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into individual columns (Address, City, State)


SELECT PropertyAddress
FROM [Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity Nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM [Nashville Housing Data for Data Cleaning]

------------------------------------------------------------------------------------------------------------------------------
--  Breaking out OwnerAddress into individual columns (Address, City, State)
-- Note: Much Better than Substrings

SELECT OwnerAddress
FROM [Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [Nashville Housing Data for Data Cleaning]


ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState Nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM [Nashville Housing Data for Data Cleaning]


--------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM [Nashville Housing Data for Data Cleaning]

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2

-- This was done because SoldAsVacant was set a bit variable at first
SELECT CONVERT(Nvarchar(50),SoldAsVacant)
, CASE WHEN CONVERT(Nvarchar(50),SoldAsVacant) = '1' THEN 'Yes'
	   WHEN CONVERT(Nvarchar(50),SoldAsVacant) = '0' THEN 'No'
	   ELSE CONVERT(Nvarchar(50),SoldAsVacant)
	   END
FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ALTER COLUMN SoldAsVacant Nvarchar(50);

UPDATE [Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = '1' THEN 'Yes'
	   WHEN SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
-- Note: Not done a lot in SQL, not standard

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

FROM [Nashville Housing Data for Data Cleaning]
--ORDER BY ParcelID	
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

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

FROM [Nashville Housing Data for Data Cleaning]
--ORDER BY ParcelID	
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM [Nashville Housing Data for Data Cleaning]


--------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
-- Note: Not done often

SELECT *
FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate