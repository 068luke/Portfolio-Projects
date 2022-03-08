Select*
From [Portfolio Project].dbo.NashvilleHousing

-- Standarize Date Format

Select SaleDateConverted, Convert(DATE, SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)



--Populate Property Address Data

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
Join [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
Join [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' PropertyAddress)) as Address

From [Portfolio Project].dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' PropertyAddress) +1, LEN(PropertyAddress))

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' PropertyAddress) +1, LEN(PropertyAddress))

Select*
From [Portfolio Project].dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N'Then 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N'Then 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

With RowNumCTE As(
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

From [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)

Select*
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Delete Unused Columns

Select*
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE
Drop COLUMN SaleDate
