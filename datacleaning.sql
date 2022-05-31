/* Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing;

--Format Sales Date

SELECT Salesdate 
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted  = CONVERT(DATE,SaleDate);

Select SaleDateConverted
FROM NashvilleHousing;

-- Populate Property Address
/* We can use the parcel id on a self join to fill in PropertyAddress cells that are blank as the parcelID should be unique to the address (in most cases) */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM  NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

--Break out Addresses to indivudal Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing;

--TEST COLUMN SPLIT
SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing;

--CREATE SPLIT COLUMNS

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress  = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity  = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) ;


--Repeat for OwnerAddress using PARSENAME

SELECT OwnerAddress	
FROM NashvilleHousing;

--TEST to ensure the split works
SELECT
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2) ;

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1) ;

--Change Y and N to Yes and No in SoldAsVacant for readability

SELECT DISTINCT(SoldasVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP by SoldAsVacant
Order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	WHEN SoldasVacant = 'N' THEN 'No'
	ELSE  SoldasVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	WHEN SoldasVacant = 'N' THEN 'No'
	ELSE  SoldasVacant
	END;

	--REMOVE DUPLICATES
	WITH  RowNumCTE AS (
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
	FROM NashvilleHousing)

DELETE  FROM 
RowNumCTE
WHERE row_num >1;


--DELETE Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate;

SELECT * 
FROM NashvilleHousing;



