-- Cleaning Data Queries

SELECT * 
FROM NashvilleHousing

-- Standardize the date (Non-aggregated commands)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Populate property address data

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
INNER JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking addresses into indivual columns


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )  AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) )  AS City 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD SplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) )

-- Cleaning Owner Address

ALTER TABLE NashvilleHousing
ADD(OwnerSplitAddress VARCHAR(255), OwnerSplitCity VARCHAR(255), OwnerSplitState VARCHAR(255))

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


-- Changing 'Sold as vacant' Field Y to Yes and N to No

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Deleting Duplicates (Careful with this)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



