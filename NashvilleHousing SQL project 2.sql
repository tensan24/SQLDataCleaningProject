/*
Cleaning Data in SQL Queries
*/

Select * 
from PortfolioProject.dbo.NashvilleHousing



--standardize sale date 

Select *
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

Alter table NashvilleHousing
Add SalesDateNew Date

Update NashvilleHousing
set SalesDateNew = CONVERT(date, SaleDate)






--Populate property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--isnull is used to command that if the a.property address is null than take a value from from b.propertyaddress

--use alias in first line while using join
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)-- can populate null with string instead as well ''.
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null







--Breaking out address into individual columns (address, city, state)


Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

--charindex uses number to address character so to avoid comma in the result, we do -1.

Alter table NashvilleHousing
Add PropertiSplitAddress nvarchar(255);

Update NashvilleHousing
set PropertiSplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertiSplitCity nvarchar(255);

Update NashvilleHousing
set PropertiSplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)




-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (Soldasvacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
from PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End





--Remove Duplicates
WITH RowNumCTE as(
Select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) Row_num
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE 
Where Row_num > 1
Order by PropertyAddress

Delete
From RowNumCTE 
Where Row_num > 1
--Order by PropertyAddress





-- Delete Unused Column

Select *
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate