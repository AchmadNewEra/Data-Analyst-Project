--DATA CLEANING
--SELECT * FROM NashVilleHouse


---------------------------------------------------------------------------------Standarize Date Format
SELECT saledate, CONVERT(date,SaleDate) AS SaleDateConvert from NashvilleHouse 

---converting date 
ALTER TABLE nashvillehouse
ADD SaleDateConvert Date

--UPDATE INSERT CONVERTING DATE
UPDATE NashvilleHouse
SET SaleDateConvert = CONVERT(date,saledate)

SELECT saledateconvert FROM NashvilleHouse

--EO Standarize Date Format
--------------------------------------------------------------------

--Populate Data Properti Alamat
-------------------------------------------------------------------
SELECT * FROM NashvilleHouse
where PropertyAddress IS NULL

--Mencari duplikat ID di kolom ParcelID
SELECT * FROM NashvilleHouse ORDER BY ParcelID
--EO Mencari Duplikat ID

--Normalisasi kolom PropertyAddress yang NULL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
FROM nashvillehouse AS a
JOIN NashvilleHouse AS b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
--EO Normalisasi

--Mengupdate yang NULL
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- note : b.propertyAddress - is not address
FROM NashvilleHouse AS a
JOIN NashvilleHouse AS b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
--EO Mengupdate yang NULL




--------------------------------------------------------------------
--Memecah Alamat Ke Individual Kolom(Address, City, State)
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1, LEN(Propertyaddress)) AS Address 
FROM NashvilleHouse

ALTER TABLE nashvillehouse
add PropertySplitAddress nvarchar(255)

ALTER TABLE nashvillehouse
add PropertySplitCity nvarchar(255)

UPDATE nashvillehouse
SET PropertySplitAddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

UPDATE NashvilleHouse
SET  PropertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1, LEN(PropertyAddress))

SELECT propertysplitcity, propertysplitaddress FROM NashvilleHouse ORDER BY propertysplitcity, PropertySplitAddress

SELECT owneraddress FROM NashvilleHouse
--------------------------------------------------------------------
--EO Memecah Alamat Ke Individual Kolom(Address, City, State)





--------------------------------------------------------------------
--Memecah OWNER ADDRESS dan memasukkan ke dlm kolom2
SELECT owneraddress FROM NashvilleHouse

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHouse

ALTER TABLE nashvillehouse
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE nashvillehouse
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE nashvillehouse
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM NashvilleHouse

--EO Memecah OWNER ADDRESS
--------------------------------------------------------------------



--------------------------------------------------------------------
--Merubah variabel SoldAsVacant dari Y dan N menjadi Yes dan No
SELECT DISTINCT(SoldAsVacant), COUNT(soldAsVacant)AS CountSoldAsVacant FROM NashvilleHouse  GROUP BY SoldAsVacant ORDER BY 2

SELECT SoldAsVacant,
CASE when soldasvacant ='Y' THEN 'Yes'
     when soldasvacant ='N' THEN 'No'
	ELSE SoldAsVacant 
END AS SAV
FROM NashvilleHouse

UPDATE NashvilleHouse
SET
SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--EO Merubah variabel SoldAsVacant dari Y dan N menjadi Yes dan No
--------------------------------------------------------------------



--------------------------------------------------------------------
--Menghapus Duplikat

--meliat nilai yang duplikat
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
		) Row_Num
FROM NashvilleHouse 
ORDER By ParcelID

--buat temp table, melihat data duplikat dan menghapusx
WITH ROWNUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY parcelID,
	propertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) Row_num
	FROM NashvilleHouse
)
SELECT * FROM  ROWNUMCTE--DELETE From ROWNUMCTE (Query untuk delete)
WHERE Row_num > 1 
ORDER BY PropertyAddress
--EO Menghapus Duplikat
--------------------------------------------------------------------



--------------------------------------------------------------------
--Menghapus Kolom Yang Tidak Terpakai

SELECT * FROM NashvilleHouse

ALTER TABLE nashvillehouse
DROP COLUMN owneraddress,propertyaddress,taxdistrict


--EO Menghapus Kolom yang tidak terpakai
--------------------------------------------------------------------