/*

Cleaning Data in SQL Queries

*/

SELECT * FROM [Portfolio Project].dbo.NashevilleHousing 

----------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date, Saledate) FROM [Portfolio Project].dbo.NashevilleHousing 

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing ALTER COLUMN SaleDate DATE

----------------------------------------------------------------

-- Populate Property Address Data

Select * 
From [Portfolio Project].dbo.NashevilleHousing 
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashevilleHousing a
JOIN [Portfolio Project].dbo.NashevilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashevilleHousing a
JOIN [Portfolio Project].dbo.NashevilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

----------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress   
From [Portfolio Project].dbo.NashevilleHousing 
--Where PropertyAddress is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM [Portfolio Project].dbo.NashevilleHousing

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
add PropertySplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashevilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
add PropertySplitCity Nvarchar(225);

UPDATE [Portfolio Project].dbo.NashevilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *   
From [Portfolio Project].dbo.NashevilleHousing 


Select OwnerAddress   
From [Portfolio Project].dbo.NashevilleHousing 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project].dbo.NashevilleHousing 

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
add OwnerSplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashevilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
add OwnerSplitCity Nvarchar(225);

UPDATE [Portfolio Project].dbo.NashevilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
add OwnerSplitState Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashevilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


----------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select distinct (SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].dbo.NashevilleHousing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 end
FROM [Portfolio Project].dbo.NashevilleHousing

UPDATE [Portfolio Project].dbo.NashevilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 end
FROM [Portfolio Project].dbo.NashevilleHousing


----------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT * , 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
						UniqueID
						) row_num

FROM [Portfolio Project].dbo.NashevilleHousing
--order by ParcelID
)
DELETE  
From RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashevilleHousing
DROP COLUMN SaleDate

Select *   
From [Portfolio Project].dbo.NashevilleHousing 
