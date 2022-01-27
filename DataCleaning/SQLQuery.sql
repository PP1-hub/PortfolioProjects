SELECT *
FROM Portfolio.dbo.Housing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
From Portfolio.dbo.Housing

UPDATE Portfolio.dbo.Housing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE Housing
Add SaleDateConverted Date;

UPDATE Housing
SET SaleDate = CONVERT(Date, SaleDate);




--Populate Property Address Data

Select *
From Portfolio.dbo.Housing
--Where PropertyAddress is null
Order by ParceliD

Select a.ParceliD, a.PropertyAddress, b.ParceliD, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.Housing a
JOIN Portfolio.dbo.Housing b
   on a.ParceliD = b.ParceliD
   AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.Housing a
JOIN Portfolio.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From Portfolio.dbo.Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Portfolio.dbo.Housing

ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);


Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Select *
From Portfolio.dbo.Housing



ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



--Breaking out OwnerAddress

Select OwnerAddress
From Portfolio.dbo.Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio.dbo.Housing


ALTER TABLE Portfolio.dbo.Housing
Add OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio.dbo.Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Portfolio.dbo.Housing
Add OwnerSplitCity Nvarchar(255);

UPDATE Portfolio.dbo.Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Portfolio.dbo.Housing
Add OwnerSplitState Nvarchar(255);

UPDATE Portfolio.dbo.Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM Portfolio.dbo.Housing



--Change Y or N in 'SoldAsVacant'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.Housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM Portfolio.dbo.Housing

Update Portfolio.dbo.Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates

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

From Portfolio.dbo.Housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Portfolio.dbo.Housing

--Delete Unused Columns

SELECT *
FROM Portfolio.dbo.Housing

ALTER TABLE Portfolio.dbo.Housing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict
