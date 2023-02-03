/* John Benson
Data cleaning of the Nashville Housing*/

USE PortfolioProject;
SELECT * FROM dbo.NashvilleHousing

--Standardize Date Format 
SELECT SaleDateConverted  , CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate the Property Address data 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
       on a.ParcelID = b.ParcelID
	   AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is not null


Update a 
SET  PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress )
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
       on a.ParcelID = b.ParcelID
	   AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is  null


--Breaking out Address into Individul columns (Address, City, State)
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing 
 
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * FROM PortfolioProject.dbo.NashvilleHousing 
-- this code seperates the address into 3 parts


--Change Y and N to Yes and No in "Sold as Vacant" field 
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant) AS TotalVacant
FROM PortfolioProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

--Lets do this by using a case statement 
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 
FROM PortfolioProject.dbo.NashvilleHousing 

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 

--Let's remove duplicates 
WITH RowNumCTE AS(
SELECT *,
      ROW_NUMBER()OVER ( PARTITION BY ParcelID,
	                                  PropertyAddress,
	                                  SalePrice,
	                                  SaleDate,
	                                  LegalReference
									  ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
--DELETE
--FROM RowNumCTE 
--WHERE row_num >1
--ORDER BY PropertyAddress 

SELECT* 
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY PropertyAddress

--Delete unsued COLUMNS
SELECT* 
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress,SaleDate