/* 
Cleaning Data in SQL Queries
*/

SELECT *
FROM NashivilleHousing

----------------------------------------------------------------------------------------------------------------------

--Standarize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashivilleHousing

ALTER TABLE NashiVilleHousing
ADD SaleDateConverted Date;

UPDATE NashivilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM NashivilleHousing

----------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM NashivilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashivilleHousing a
JOIN NashivilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashivilleHousing a
JOIN NashivilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
----------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashivilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashivilleHousing

ALTER TABLE NashivilleHousing
ADD PropertySpiltAddress NVARCHAR(255);

UPDATE NashivilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashivilleHousing
ADD PropertySpiltCity NVARCHAR(255);

UPDATE NashivilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashivilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM NashivilleHousing

ALTER TABLE NashiVilleHousing
ADD OwnerPropertySpiltAddress NVARCHAR(255);

UPDATE NashivilleHousing
SET OwnerPropertySpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashiVilleHousing
ADD OwnerPropertySpiltState NVARCHAR(255);

UPDATE NashivilleHousing
SET OwnerPropertySpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE NashiVilleHousing
ADD OwnerPropertySpiltCity NVARCHAR(255);

UPDATE NashivilleHousing
SET OwnerPropertySpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

----------------------------------------------------------------------------------------------------------------------
--Replace Y and N to Yes and No in "Sold As Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashivilleHousing
GROUP BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
FROM NashivilleHousing

UPDATE NashivilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END

----------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashivilleHousing
)
Select * 
--DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM NashivilleHousing

----------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM NashivilleHousing

ALTER TABLE NashivilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate