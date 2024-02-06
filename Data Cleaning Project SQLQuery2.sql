
--DATA CLEANING IN SQL 

select *
from [PortfolioProject]..NashvilleHousing


-- standardize Date Format for SaleDate column

select SaleDate
from [PortfolioProject]..NashvilleHousing

select SaleDate, convert(Date, SaleDate)
from [Portfolio Project]..NashvilleHousing

--add a new column and populate it with new date converted
alter table PortfolioProject..NashvilleHousing
add SaleDate1 Date;

update [PortfolioProject]..NashvilleHousing 
set SaleDate1 = convert(Date, SaleDate)


-- lets view the new column SaleDate1 and SaleDate
select SaleDate, SaleDate1
from [PortfolioProject]..NashvilleHousing


--POPULATE PROPERTY ADDRESS DATA COLUMN 

select *
from PortfolioProject..NashvilleHousing

--lets check for null values with propertyaddress column (run again to check after populating propertyAddress)
select *
from PortfolioProject..NashvilleHousing
where propertyaddress is null
order by ParcelID

select *
from PortfolioProject..NashvilleHousing
--where propertyaddress is null
order by ParcelID

-- we dicover that porperties with the same parcelID have the same propertyAddress

-- we will join this table to itself and compare both tables populating the propertyAddress that have the same parcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.uniqueID
where a.PropertyAddress is null

-- Now Lets Update the Table 
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.uniqueID
where a.PropertyAddress is null

-- PropertyAddress Populated 
-- run the second query under PropertyAddress to verify no null values



---BREAKING ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)

---PROPERTY ADDRESS

Select PropertyAddress 
from PortfolioProject..NashvilleHousing 


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing 


--Now that we got it 
--lets update the table with two new column for PropertyAddress(Address and City)

alter table PortfolioProject..NashvilleHousing
add PAddress NVARCHAR(255);

update [PortfolioProject]..NashvilleHousing 
set PAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

alter table PortfolioProject..NashvilleHousing
add PAcity NVARCHAR(255);

update [PortfolioProject]..NashvilleHousing 
set PAcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) 

--lets check the table for the new updates

select propertyAddress, PAddress, PAcity 
from [PortfolioProject]..NashvilleHousing


---OWNER ADDRESS

Select OwnerAddress
from [PortfolioProject]..NashvilleHousing
order by ParcelID

Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3) as Address
,PARSENAME(replace(OwnerAddress, ',', '.'), 2) as City
,PARSENAME(replace(OwnerAddress, ',', '.'), 1) as State
from [PortfolioProject]..NashvilleHousing
order by ParcelID

--Lets Alter the Table by Updating the Owners Address

alter table PortfolioProject..NashvilleHousing
add OAddress NVARCHAR(255);

update [PortfolioProject]..NashvilleHousing 
set OAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject..NashvilleHousing
add Ocity NVARCHAR(255);

update [PortfolioProject]..NashvilleHousing 
set Ocity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject..NashvilleHousing
add Ostate NVARCHAR(255);

update [PortfolioProject]..NashvilleHousing 
set Ostate = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

--Lets check our new updated columns

select OAddress, Ocity, Ostate
from [PortfolioProject]..NashvilleHousing



---SOLD AS VACAANT COLUMN 
--CHANGE Y TO YES AND N TO NO 

SELECT SoldAsVacant 
from [PortfolioProject]..NashvilleHousing

--lets check distinct count 

SELECT distinct(SoldAsVacant) 
from [PortfolioProject]..NashvilleHousing

--lets counts each distinct data oocurence in SoldAsVacant column 

SELECT distinct(SoldAsVacant), count(SoldAsVacant) 
from [PortfolioProject]..NashvilleHousing
Group by SoldAsVacant
order by 2


SELECT SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
from [PortfolioProject]..NashvilleHousing

-- Lets update our table with the case query staement 

update [PortfolioProject]..NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
from [PortfolioProject]..NashvilleHousing



-- REMOVING DUPLICATES 

with RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
from [PortfolioProject]..NashvilleHousing
)

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress 