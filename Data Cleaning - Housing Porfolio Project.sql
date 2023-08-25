-- Data Cleaning
-- Nashville Housing Project

select *
From NashvilleHousing
--Where PropertyAddress is null




--Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(Date, SaleDate)




-- Populate Property Address Data where it's null using self join

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
--Where PropertyAddress is null
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
--Where PropertyAddress is null
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null





-- Breaking out Property Address into Individual Columns (Address,City)
--Using Substring

Select PropertyAddress
From NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




--Using Parsename to split Owner Address into Address, City, State

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',','.') , 3)
,PARSENAME(Replace(OwnerAddress, ',','.') , 2)
,PARSENAME(Replace(OwnerAddress, ',','.') , 1)
From NashvilleHousing

Alter Table NashvilleHousing
ADD OwnerAddressSplit NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(Replace(OwnerAddress, ',','.') , 3)

Alter Table NashvilleHousing
ADD OwnerCitySplit NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerCitySplit = PARSENAME(Replace(OwnerAddress, ',','.') , 2)

Alter table NashvilleHousing
Add OwnerStateSplit NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerStateSplit = PARSENAME(Replace(OwnerAddress, ',','.') , 1)


--Change Y and N to Yes and No in "Sold as Vacant" field
-- Case statement

Select Distinct(SoldasVacant), Count(SoldAsVacant)
From NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = 
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Remove Duplicates
--Using Row Number combined with CTE, Partition by

WITH RowNumCTE as(
Select *,
ROW_NUMBER() OVER (
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER by
				UniqueID
				) row_num
FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
Where row_num > 1



-- Delete Unused Columns

Alter Table NashvilleHousing
DROP Column OwnerAddress, SaleDate, TaxDistrict, PropertyAddress

