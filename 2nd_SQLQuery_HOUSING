-- OVERVIEW the NashvilleHousing table
SELECT		*
FROM		NashvilleHousing

-- STANDARD date format (DD-MM-YYYY)
ALTER TABLE	NashvilleHousing
	ADD		Standarddate date
ALTER TABLE NashvilleHousing
	ADD		Standarddate_vn VARCHAR(10)

UPDATE		NashvilleHousing
SET			Standarddate = CONVERT(date,SaleDate)

SELECT		SaleDate,
			Standarddate,
			CONVERT(VARCHAR(10), CAST(Standarddate AS DATETIME), 105) AS Standarddate_vn
FROM		NashvilleHousing

UPDATE		NashvilleHousing
SET			Standarddate_vn = CONVERT(VARCHAR(10), CAST(Standarddate AS DATETIME), 105)

SELECT		*
FROM		NashvilleHousing



-- POPULATE Property Address data (Điền Property Address)
--step1
SELECT		*
FROM		NashvilleHousing
WHERE		PropertyAddress IS NOT NULL
ORDER BY	ParcelID

--step2
SELECT		a.ParcelID
			,a.PropertyAddress
			,b.ParcelID
			,b.PropertyAddress
			,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM		NashvilleHousing a
JOIN 		NashvilleHousing b
	ON			a.ParcelID = b.ParcelID
	AND			a.[UniqueID ] <> b.[UniqueID ]
WHERE		a.PropertyAddress IS NULL

--step3
UPDATE		a
SET			PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM		NashvilleHousing a
JOIN 		NashvilleHousing b
	ON			a.ParcelID = b.ParcelID
	AND			a.[UniqueID ] <> b.[UniqueID ]
WHERE		a.PropertyAddress IS NULL		

SELECT		*
FROM		NashvilleHousing
WHERE		PropertyAddress IS NULL
ORDER BY	ParcelID

-- BREAKING OUT Address into individual columns (Address, City, State)
-- using SUBSTRING
SELECT	PropertyAddress
		,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
		,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM	NashvilleHousing

ALTER TABLE	NashvilleHousing
ADD			Property_SlitAddress NVARCHAR(255);
UPDATE		NashvilleHousing
SET			Property_SlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE	NashvilleHousing
ADD			Property_SlitCity NVARCHAR(255);
UPDATE		NashvilleHousing
SET			Property_SlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT	*
FROM	NashvilleHousing


--------------------------------------------------------------------------------
-- BREAKING OUT Address into individual columns (Address, City, State)
-- using PARSENAME
SELECT	OwnerAddress
		,PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
		,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
		,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM	NashvilleHousing

ALTER TABLE	NashvilleHousing
ADD			Owner_SlitAddress NVARCHAR(255);
UPDATE		NashvilleHousing
SET			Owner_SlitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE	NashvilleHousing
ADD			Owner_SlitCity NVARCHAR(255);
UPDATE		NashvilleHousing
SET			Owner_SlitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE	NashvilleHousing
ADD			Owner_SlitState NVARCHAR(255);
UPDATE		NashvilleHousing
SET			Owner_SlitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT	*
FROM	NashvilleHousing

-- CHANGE Y and N to Yes and No in 'Sold as Vacant' field
SELECT	DISTINCT(SoldAsVacant)
		,COUNT(SoldAsVacant) AS	Count_SoldAsVacant
FROM	NashvilleHousing
GROUP BY	SoldAsVacant

SELECT	SoldAsVacant
		,CASE WHEN SoldAsVacant = 'Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
			  WHEN SoldAsVacant = 'N' THEN REPLACE(SoldAsVacant, 'N', 'No') ELSE SoldAsVacant 
		 END	
FROM	NashvilleHousing
WHERE	SoldAsVacant = 'Y'

UPDATE		NashvilleHousing
SET			SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
								WHEN SoldAsVacant = 'N' THEN REPLACE(SoldAsVacant, 'N', 'No') ELSE SoldAsVacant 
							END	

SELECT	DISTINCT(SoldAsVacant)
		,COUNT(SoldAsVacant) AS	Count_SoldAsVacant
FROM	NashvilleHousing
GROUP BY	SoldAsVacant

-- REMOVE Duplicates
WITH rownum_CTE AS
				(
					SELECT		*
								,ROW_NUMBER()	OVER (PARTITION BY	ParcelID,
																	PropertyAddress,
																	SalePrice,
																	SaleDate,
																	LegalReference
											ORDER BY UniqueID) AS row_num
					FROM		NashvilleHousing
					--ORDER BY	ParcelID
				)

SELECT		*
FROM		rownum_CTE
WHERE		row_num > 1

DELETE		
FROM		rownum_CTE
WHERE		row_num > 1

-- REMOVE Unused Columns 
ALTER TABLE	NashvilleHousing
	DROP COLUMN	OwnerAddress,
				TaxDistrict,
				PropertyAddress,
				SaleDate

SELECT	*
FROM	NashvilleHousing
